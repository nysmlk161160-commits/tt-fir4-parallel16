import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer

async def edge(dut):
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

async def command(dut, code, data):
    await FallingEdge(dut.clk)
    dut.ui_in.value = data & 255
    dut.uio_in.value = code | 0x80
    await edge(dut)
    pulse = int(dut.uio_out.value) & 1
    await FallingEdge(dut.clk)
    dut.uio_in.value = 0
    await edge(dut)
    return pulse

async def write_coeff(dut, index, value):
    await command(dut, 2, index)
    await command(dut, 3, value)
    await command(dut, 4, (value >> 8))

async def write_sample(dut, value):
    await command(dut, 0, value)
    return await command(dut, 1, value >> 8)

async def read_result(dut):
    await FallingEdge(dut.clk)
    dut.uio_in.value = 0
    await Timer(1, unit="ns")
    lo = int(dut.uo_out.value)
    dut.uio_in.value = 8
    await Timer(1, unit="ns")
    hi = int(dut.uo_out.value)
    raw = (hi << 8) | lo
    return raw - 65536 if raw & 0x8000 else raw

def s16(x):
    x &= 65535
    return x - 65536 if x & 32768 else x

@cocotb.test()
async def fir_test(dut):
    dut.clk.value = 0
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    for _ in range(4):
        await edge(dut)
    await FallingEdge(dut.clk)
    dut.rst_n.value = 1
    await edge(dut)
    coeffs = [0x4000, 0x2000, 0x1000, 0x0800]
    for i, c in enumerate(coeffs):
        await write_coeff(dut, i, c)
    history = [0, 0, 0]
    samples = [8000, 0, 0, 0, 0, -8000, 16000, -32000]
    rng = random.Random(42)
    samples += [rng.randint(-32768, 32767) for _ in range(30)]
    for x in samples:
        ideal = (s16(x)*s16(coeffs[0]) + sum(history[i]*s16(coeffs[i+1]) for i in range(3))) >> 15
        expected = s16(ideal)
        pulse = await write_sample(dut, x)
        assert pulse == 1, "out_valid was not raised on sample commit"
        result = await read_result(dut)
        assert result == expected, f"input={x} expected={expected} got={result}"
        history = [s16(x)] + history[:2]
    assert int(dut.uio_oe.value) == 1
