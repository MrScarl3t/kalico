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

## Branch contents (k1_max_kalico, as of milestone 1)

- `klippy/compat.py`, `klippy/configfile.py`, `klippy/extras/gcode_macro.py`, `pyproject.toml`: Python 3.8 compatibility patches.
- `klippy/queuelogger.py`: rollover fix from upstream k1-port.
- `klippy/chelper/Makefile`, `klippy/chelper/__init__.py`: cross-compile path for MIPS host.
- `.config.host`: Linux host MCU Kconfig.
- `scripts/build-k1-host.sh`: ELF-checked cross-build wrapper.
- `klippy/extras/virtual_pins.py`: virtual pin MCU shim for sensorless homing.
- `klippy/extras/bl24c16f.py`: BL24C16F EEPROM I2C (GPLv3, Callahan/Creality).
- `klippy/extras/custom_macro.py`: CX_* gcode commands (GPLv3, Lord/Creality). REVIEW note: ACCEL_TO_DECEL in CX_PRINT_DRAW_ONE_LINE.
- `klippy/extras/fan_feedback.py`: fan tachometer (GPLv3, Creality). Requires vendor `fancheck` MCU command set.
- `klippy/extras/prtouch_v2.py`: probe wrapper (GPLv3, Creality). Requires `prtouch_v{1,2}_wrapper.cpython-38-mipsel-linux-gnu.so` at runtime.
- `scripts/opencreality.sh`: mode selector (`opencreality mode opencreality|stock`, `opencreality status`).
- `scripts/init.d/S55oc_kalico`, `S56oc_moonraker`, `S57oc_web`: init scripts for the opencreality runtime.
- `docs/k1-max-deployment.md`: deployment runbook with preconditions, staged plan, and rollback.

## Remaining blockers

- ~~No MIPS LE toolchain~~ resolved: see Local build evidence.
- ~~Vendor extras missing~~ resolved: `bl24c16f`, `custom_macro`, `fan_feedback`, `prtouch_v2` all ported (GPLv3).
- `prtouch_v{1,2}_wrapper.cpython-38-mipsel-linux-gnu.so`: stripped MIPS binaries, not in repo. Must be copied from the printer's own `/usr/share/klipper/klippy/extras/` at deploy time. Cannot be tested without the printer.
- `fan_feedback.py` requires vendor `fancheck`/`query_fancheck` MCU commands. Only the vendor MCU firmware supports them; Kalico MCU firmware does not. This module will fail at runtime if the MCU is re-flashed with Kalico firmware.
- Host-to-vendor-MCU protocol compatibility: the vendor MCU dictionaries differ from Kalico MCU binaries. MCU flashing is prohibited until protocol compatibility is established per MCU target.
- Python 3.8 dependency versions: not yet validated in an isolated MIPS build. The printer's site-packages (`numpy 1.16.4`, `cffi 1.13.1`, `greenlet 0.4.15`, `jinja2 2.11.3`) must be tested against Kalico imports.
- Offline config-load test: `c_helper.so` has not been loaded by MIPS Python 3.8. Requires either the printer (SSH) or QEMU emulation with the stock rootfs (`emu-stock.sh`).
- `gen-config.py` in k1-clean still lists `bl24c16f`, `custom_macro`, and `fan_feedback` under `DROP_SECTIONS` (no Kalico module). Now that we have them, update it to keep those sections — but that is in the k1-clean repo, not here.
- Toolchain archive (`tc.tgz`) provenance unrecorded.
- Deployment, MCU flashing, service changes, Wi-Fi, reboot, heat, and motion require separate approval.

## MIPS emulation test evidence (2/2 PASS)

- Source: `72e0d472` (HEAD at time of test).
- Rootfs: `/home/thijs/k1fw36/root` (stock Creality 1.3.6 squashfs, Python 3.8.2 MIPS).
- Runtime: `qemu-mipsel -cpu P5600` under `bwrap` (no network, no serial, no printer hardware).
- `c_helper.so`: `6fba2ff6…` (built from same HEAD, Ingenic toolchain).
- PASS 1: `chelper.get_ffi()` succeeds; `lib.trapq_alloc()/free()` called; prints `python 3.8.2 mips c_helper ok`.
- PASS 2: `klippy.py --help` returns `Usage: klippy [options] <config file>` using stock `/usr/share/klippy-env/bin/python`.
- Not tested: config load with MCUs, vendor extras, full printer.cfg parse.

## Next actions (ordered)

1. Run `emu-stock.sh` against our branch commit to verify `c_helper.so` loads in the stock MIPS Python 3.8 (need rootfs).
2. Update k1-clean `gen-config.py` `DROP_SECTIONS` to remove `bl24c16f`, `custom_macro`, `fan_feedback` and test config generation.
3. Validate Moonraker Python 3.8 wheel compatibility against the stock site-packages.
4. Fill in the k1max hardware profile from the backup and generate a candidate config.
5. Deployment approval: separate decision required before any printer write.
