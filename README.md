# Parallel 4-tap 16-bit FIR — Tiny Tapeout SKY130 overlay

This zip is a **complete set of replacement/new files** for the official `TinyTapeout/ttsky-verilog-template` repository. It is not the full original template (which contains official GitHub workflows and default physical config).

## Create your new repo

1. Open https://github.com/TinyTapeout/ttsky-verilog-template and choose **Use this template → Create a new repository**. Choose e.g. `tt-fir4-parallel16`.
2. In your new repo, upload/replace files from this package, preserving directory names:
   - `src/project.v` REPLACE
   - `src/fir_4tap.v` ADD
   - `info.yaml` REPLACE
   - `test/Makefile`, `test/tb.v`, `test/test.py` REPLACE
   - `docs/info.md` REPLACE
   - `README.md` optionally REPLACE
3. Keep the official `.github/workflows/*`, `src/config.json` and all other template files unchanged initially.
4. Commit the changes and open GitHub **Actions**. The template's `test` and `gds` workflows are triggered by the push. Look for `gds` → `Build GDS` / `Precheck` / `GL test` and the generated artifact/results viewer.
5. If the design fails floorplanning / placement / routing because of area, that's an actual result. Do not claim a GDS was created. Consider 1x2 tiles for a diagnostic (only if your coursework allows it), or compare smaller architecture variants to stay in 1x1.

## Local RTL simulation

With Icarus Verilog and Cocotb installed:

```bash
cd test
make -B
```

## First meaningful experiment

Compare this parallel 4x16x16 FIR against one-multiplier four-cycle FIR at the **same data width, coefficients, numerical behaviour and physical constraints**. Measure post-route area, clock, latency, throughput, DRC and LVS.

## Important

No repository has been created in your GitHub account; the zip is for you to upload. No silicon implementation or GDS success has yet been verified in this environment.
