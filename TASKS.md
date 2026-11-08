# K1 Max preparation

## Verified state

- Repository: `C:\Users\Thijs\Documents\projkalico\kalico`.
- Origin: `https://github.com/MrScarl3t/kalico.git`.
- Working branch: `k1_max_kalico`.
- Pre-existing unrelated worktree change preserved: `.gitignore` adds `.claude/*`.
- Printer access remained read-only. No upload, restart, reboot, network change, flash, heat, or motion was performed.
- Printer: Creality K1 Max, hostname `K1Max-4E07`, Buildroot 2020.02.1, kernel 4.4.94, Ingenic XBurst2 MIPS little-endian.
- Printer Python: 3.8.2, `cpython-38-mipsel-linux-gnu`, 32-bit, glibc loader `/lib/ld-linux-mipsn8.so.1` backed by glibc 2.29.
- Printer storage: read-only squashfs `/rom`, writable overlay, `/usr/data` on `/dev/mmcblk0p10`.
- Vendor host MCU: Linux MCU at `/tmp/klipper_host_mcu`, 50 MHz, vendor Klipper v0.11.0-372.
- Vendor physical MCUs: `gd32f303xe` at `/dev/ttyS7`, `gd32f303xb` at `/dev/ttyS1`, and `gd32e230x8` at `/dev/ttyS9`, all 230400 baud.
- Vendor extras present: `prtouch_v2`, `bl24c16f`, `fan_feedback`, `custom_macro`, `virtual_pins`, and native MIPS `prtouch_*_wrapper` modules.
- Vendor MCU dictionaries contain Creality-specific `prtouch`, `fancheck`, `dirzctl`, and HX711S commands.
- Fork K1 MCU binaries contain fewer commands and do not provide the vendor-specific command set. MCU compatibility is therefore unverified and MCU flashing is prohibited.
- Moonraker and Fluidd already run on the printer. Moonraker is LAN-trusted without login; this is a deployment security issue to address later.

## Evidence and backups

- Read-only API/config/log backup: `/home/thijs/k1max-backups/k1max-20261107-183834`.
- Backup manifest verified: 37/37 files passed SHA-256 checks.
- Read-only vendor host tree archive: `host/vendor-host.tar.gz` in that backup.
- Extracted vendor host tree: `host/x/`.
- SSH inventories: `api/ssh_inventory.txt`, `api/ssh_inventory2.txt`, `api/ssh_inventory3.txt`.
- Vendor host binary and `prtouch` wrappers were confirmed ELF32 little-endian MIPS32 o32 NAN2008.
- The backup contains an OTA image filename and vendor MCU firmware files; neither was modified or used.

## Preparation changes on this branch

- Added Python 3.8 syntax compatibility for import aliases, config Python blocks, and `!python` macro globals.
- Changed the project Python lower bound to 3.8 and added the fork's Python-3.8 NumPy marker. Exact installable versions for all dependencies remain to be validated before deployment.
- Added `klippy/extras/virtual_pins.py` from the reviewed K1 fork.
- Added a cross-prefix-required `klippy/chelper/Makefile`.
- Added `.config.host` for the Linux host MCU.
- Added `scripts/build-k1-host.sh`, which refuses an unspecified toolchain and validates ELF32 little-endian MIPS o32 NAN2008 output.
- Changed `klippy/chelper/__init__.py` to use a prebuilt helper only when no compiler exists; normal native builds remain unchanged.
- No generated firmware or `c_helper.so` binary was added.

## Checks completed

- Python 3.8 `compileall` passed for `klippy` and `scripts` before the final documentation additions.
- `scripts/build-k1-host.sh` syntax check passed.
- The build script correctly refuses a missing `CROSS_PREFIX` and a nonexistent compiler.
- The chelper Makefile's object list matches the current `SOURCE_FILES` list (20 objects).
- `git diff --check` passed before the final documentation additions.

## Local build evidence

Status: buildable = yes. Deployable, flashed/installed, boot-ready, Moonraker/Fluidd functional, physically validated = no.

- Source: `438e41267b5787895b3d6307bbab80a03f718b9f`, built from a `git archive HEAD` export at `/home/thijs/k1build/src` in WSL Ubuntu. The `/mnt/c` worktree is not usable for builds: `core.autocrlf=true` checks out CRLF files and `scripts/find-firmware-extras.sh` then fails.
- Toolchain: `/home/thijs/k1dl/toolchain/mips-gcc720-glibc229` (Ingenic Linux-Release5.0.2 xburst2, glibc 2.29, gcc 7.2.0). Prefix is `mips-linux-gnu-` but the target is little-endian. `tc.tgz` sha256 `c0415a857c6b384820ec61b8a30c89e528585f3ef07d580fc856e80313c9d2e8`. No published provenance record for the archive yet.
- Command: `CROSS_PREFIX=/home/thijs/k1dl/toolchain/mips-gcc720-glibc229/bin/mips-linux-gnu- bash scripts/build-k1-host.sh`, exit 0, log `/home/thijs/k1build/build.log`.
- Artifacts in `/home/thijs/k1build/artifacts` (SHA-256):
  - `c_helper.so` `6fba2ff61fd68f345af7682aa61a43072e4a127fddd796a2cec205791316dfe1`
  - `klipper_host_mcu` `0220315f7c1b2115e67f612ca615e1d091161f248fc9711a88dbd19bad25bda4`
  - `config.host` `8b3df04aadbbc19879abe17f2cf987dbcb9b09a987d0416df5cabffdb1a84318`
- ELF check: ELF32 little-endian MIPS32r2 o32 NAN2008 (`c_helper.so` flags 0x70001407, `klipper_host_mcu` flags 0x70001405). Highest symbol version GLIBC_2.28; printer has glibc 2.29.
- Dynamic deps: `c_helper.so` needs libc.so.6; `klipper_host_mcu` needs libutil, librt, libpthread, libc.
- Emulation: `klipper_host_mcu` starts under `qemu-mipsel -cpu P5600` with the toolchain sysroot and prints usage. QEMU models 24Kc, XBurstR1 and XBurstR2 reject NAN2008. This is not hardware verification.
- Not done: `c_helper.so` was not loaded by a MIPS Python 3.8 (none available locally). Nothing was run on the printer.
- The older `c_helper.so` in `/home/thijs/k1em/in/host-a` was built from kalico `e815031`. Six chelper C commits landed since. Do not use it.

## Remaining blockers

- ~~No MIPS LE toolchain~~ resolved for building: see Local build evidence. Archive provenance still unrecorded.
- Current Kalico still lacks `prtouch_v2`, its native wrappers, `bl24c16f`, `fan_feedback`, and `custom_macro`. These cannot be removed or bypassed to obtain `ready`.
- Host-to-vendor-MCU protocol compatibility is not established. The vendor MCU dictionaries and fork binaries differ materially.
- Exact dependency pins that can install on Python 3.8 and run on MIPS remain to be validated in an isolated build environment.
- Deployment, MCU flashing, service changes, Wi-Fi changes, reboot, heat, and motion remain out of scope.

## Next action

Choose a verified little-endian MIPS toolchain/sysroot, port or obtain the vendor probing modules with source/provenance, and run an offline host build and config-load test. Stop before printer deployment and require a separate deployment decision.
