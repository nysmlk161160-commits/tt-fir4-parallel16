# 4-tap 16-bit parallel FIR

Four signed 16x16 combinational multipliers, a 34-bit sum and a registered 16-bit output. Coefficients are programmable signed Q1.15, samples are signed 16-bit integers. The output truncates/wraps to 16 bits after arithmetic right shift by 15; no rounding or saturation.

The FIR result for x[n] uses x[n], x[n-1], x[n-2], and x[n-3]. Output is registered on the accepted sample high-byte command.

## Pin protocol

`ui_in[7:0]` carries an 8-bit payload. `uio_in[7]` is a synchronous rising-edge command strobe: drive 0 for at least one clock between strobe pulses. `uio_in[2:0]` selects the command:

- `0`: latch sample low byte
- `1`: commit sample high byte; generate output
- `2`: select coefficient index 0..3
- `3`: latch coefficient low byte
- `4`: commit coefficient high byte

`uio_in[3]` selects the output byte (0 low, 1 high) through `uo_out[7:0]`. `uio_out[0]` is a one-clock `out_valid` pulse. All other `uio_out` pins are outputs driven zero only when enabled; `uio_oe=8'h01` means only bit 0 is configured as output and remaining pins are inputs.

Reset clears samples, coefficients, and output. Program coefficients before sending samples. Coefficient updates affect subsequent samples.

## Constraints

This is a course-scale parallel-FIR experiment, not a guaranteed 1x1-tile fit. Actual area, PPA, DRC, LVS and GDS success require the official Tiny Tapeout build.
