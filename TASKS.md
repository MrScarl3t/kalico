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

## Remaining blockers

- No verified little-endian MIPS cross-toolchain is installed in WSL. Ubuntu did not expose a candidate for `gcc-mipsel-linux-gnu` in the checked package index. Do not substitute the big-endian `mips-linux-gnu-` compiler.
- Current Kalico still lacks `prtouch_v2`, its native wrappers, `bl24c16f`, `fan_feedback`, and `custom_macro`. These cannot be removed or bypassed to obtain `ready`.
- Host-to-vendor-MCU protocol compatibility is not established. The vendor MCU dictionaries and fork binaries differ materially.
- Exact dependency pins that can install on Python 3.8 and run on MIPS remain to be validated in an isolated build environment.
- Deployment, MCU flashing, service changes, Wi-Fi changes, reboot, heat, and motion remain out of scope.

## Next action

Choose a verified little-endian MIPS toolchain/sysroot, port or obtain the vendor probing modules with source/provenance, and run an offline host build and config-load test. Stop before printer deployment and require a separate deployment decision.
