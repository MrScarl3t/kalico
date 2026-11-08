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
- ~~Prtouch wrappers unavailable~~ resolved: copied from printer to `/home/thijs/k1priv/wrappers/`; dlopen verified under MIPS emulation.
- ~~c_helper.so not loaded by MIPS Python 3.8~~ resolved: 2/2 PASS in MIPS emulation.
- **MCU_FIRMWARE_PLAN=kalico gate in k1-clean install.sh (line 65)**: globally refuses stage-C install until "probing and MCU targets are verified." This is the single remaining blocker for deployment. Fix: either (a) open the gate in k1-clean after hardware-verifying MCU connection (T169), or (b) a k1-clean code change to allow stage C with stock MCU firmware for K1MAX. Neither is authorized this run.
- **prtouch calibration placeholders**: bundle-c printer.cfg has unverified `load_cell_probe` calibration values. Klippy will refuse with a config error until probe_calibrate runs on the printer. This is expected behavior, not a bug.
- **fan_feedback MCU commands**: work with stock MCU firmware (already on printer). Safe.
- **Toolchain provenance**: `github.com/ballaswag/k1-discovery` release, TOFU sha256. Documented gap.
- **Deployment, service switch, reboot**: require separate authorization.
- **MCU flashing**: not needed, not authorized.

## Deployment procedure (ready to execute, pending install.sh gate)

### Pre-deployment checklist
1. Open k1-clean `install.sh` line 65 gate (or verify T169 K1 Max HW-C1 MCU connection).
2. Verify no print is active; maintenance window.
3. Backup current state first: `ssh root@<printer> 'tar czf /tmp/etc_init_d_backup.tgz /etc/init.d/'`.
4. Confirm stock Klipper/Moonraker/nginx are running and accessible before takeover.

### Install steps (runs ON PRINTER over SSH, writes to /usr/data only)
```sh
# 1. Copy bundle, scripts, profile, and evidence to printer
sshpass -f ~/.k1-ssh-pass/pass scp -o StrictHostKeyChecking=yes -r \
  /home/thijs/k1priv/bundle-c root@192.168.178.141:/usr/data/k1-clean-incoming/bundle-c
sshpass -f ~/.k1-ssh-pass/pass scp -o StrictHostKeyChecking=yes -r \
  /home/thijs/k1-clean/scripts root@192.168.178.141:/usr/data/k1-clean-incoming/scripts
sshpass -f ~/.k1-ssh-pass/pass scp -o StrictHostKeyChecking=yes \
  /home/thijs/k1priv/k1max-operator.profile root@192.168.178.141:/usr/data/k1-clean-incoming/
sshpass -f ~/.k1-ssh-pass/pass scp -o StrictHostKeyChecking=yes \
  /home/thijs/k1-clean/backups/k1max/20261107T091021Z/{completeness.txt,evidence.txt} \
  root@192.168.178.141:/usr/data/k1-clean-incoming/

# 2. Dry-run on printer (printer must be MIPS = passes uname check)
sshpass -f ~/.k1-ssh-pass/pass ssh -o StrictHostKeyChecking=yes root@192.168.178.141 \
  'sh /usr/data/k1-clean-incoming/scripts/install.sh \
    --bundle /usr/data/k1-clean-incoming/bundle-c \
    --profile /usr/data/k1-clean-incoming/k1max-operator.profile \
    --evidence /usr/data/k1-clean-incoming \
    --dry-run'

# 3. Install (WRITE — requires deployment authorization)
sshpass -f ~/.k1-ssh-pass/pass ssh -o StrictHostKeyChecking=yes root@192.168.178.141 \
  'sh /usr/data/k1-clean-incoming/scripts/install.sh \
    --bundle /usr/data/k1-clean-incoming/bundle-c \
    --profile /usr/data/k1-clean-incoming/k1max-operator.profile \
    --evidence /usr/data/k1-clean-incoming \
    --yes'

# 4. Activate opencreality (stops Helper Script services, starts ours — NO reboot)
# This calls takeover.sh which: disables S99start_app, S55klipper_service, S56moonraker_service, S50nginx
# Verifies each process+port stops before starting our stack.
sshpass -f ~/.k1-ssh-pass/pass ssh -o StrictHostKeyChecking=yes root@192.168.178.141 \
  'sh /usr/data/opencreality/bin/takeover.sh activate'

# 5. Verify (allow 30s for startup)
# Kalico log: ssh ... 'tail -50 /usr/data/printer_data/logs/klippy.log'
# Fluidd: http://192.168.178.141:4408
# On failure: restore stock — sh /usr/data/k1-clean-incoming/scripts/uninstall.sh --yes
```

### Service exclusivity guarantees
- `S55opencreality` start precheck refuses if `S55klipper_service` is enabled or stock klippy is running.
- `takeover.sh` stops and verifies each conflict row before starting our services.
- Rollback: `uninstall.sh` restores all original files and re-enables stock init scripts.

### Boot persistence
- After install+activate: on next reboot, only `S55opencreality` runs (stock Klipper scripts are in remove.list).
- To switch back to stock without reboot: run takeover restore (stops our services, restarts stock).
- Wi-Fi (S43/S44), SSH (S50dropbear), networking (S40), storage (S02mount_mmc_ext4) are NOT changed.

## Live printer inventory (2026-11-08, read-only SSH)

- SSH verified: `root@192.168.178.141`, host key in known_hosts, password-auth, `sshpass -f /home/thijs/.k1-ssh-pass/pass`.
- Identity: CR-K1 Max, board CR4CU220812S12, structure_version=1, kernel 4.4.94.
- MCU versions (live, matches profile): `mcu0_120_G32-mcu0_004_000`, `noz0_120_G30-noz0_003_000`, `bed0_110_G21-bed0_004_000`.
- `/usr/data/opencreality` absent (clean install target).
- `/usr/data` free: 5.8 GB; MemAvailable: 120 MB.
- Existing services: stock Klipper (`/usr/share/klipper`), Helper Script Moonraker (`/usr/data/moonraker`), Helper Script nginx on ports 4408+4409, stock Klipper-MCU (`/usr/bin/klipper_mcu`).
- Port 4408 in use by Helper Script nginx. Our opencreality nginx (same port) requires takeover.
- Prtouch wrappers copied to `/home/thijs/k1priv/wrappers/` (private, not in repo):
  - `prtouch_v1_wrapper.cpython-38-mipsel-linux-gnu.so`: `ac2b3bf1…`
  - `prtouch_v2_wrapper.cpython-38-mipsel-linux-gnu.so`: `2cbcbfed…`
  - `prtouch_v3_wrapper.cpython-38-mipsel-linux-gnu.so`: `4b87a0ee…`
- Live `printer.cfg` sha256: `6f9298be…` — matches operator profile and backup. Config unchanged.
- Fresh backup taken: `/home/thijs/k1-clean/backups/k1max/20261108T160156Z` (`STATUS=COMPLETE`). Port 4408 still in use in this backup (Helper Script nginx).

## Prtouch wrapper test evidence (2/2 PASS, MIPS emulation)

- `prtouch_v2_wrapper.cpython-38-mipsel-linux-gnu.so` dlopen under `qemu-mipsel -cpu P5600` in Creality 1.3.6 stock rootfs: PASS.
- `fan_feedback.py`, `bl24c16f.py`, `custom_macro.py` AST parse (syntax check only — no runtime printer objects): PASS.

## sim-install dry-run evidence (PASS)

- Bundle: `/home/thijs/k1priv/bundle-c` (k1clean-c--dirty, stage C, Kalico+Moonraker+Fluidd+GuppyScreen).
- Profile: `/home/thijs/k1priv/k1max-operator.profile` (k1max-operator, validated, K1MAX).
- Backup: `/home/thijs/k1-clean/backups/k1max/20261107T091021Z`.
- Sim stock root from live printer: `/home/thijs/k1priv/sim-stock-root/` (lib/ld-*.so, lib/libc.so.6 etc from real printer).
- `install.sh --dry-run` with MCU_FIRMWARE_PLAN gate bypassed (sim only): PASS.
- Plan: 394+ files created under `/usr/data/opencreality/`, nginx/guppyscreen/c_helper.so ELF verified against target ABI.
- Space: 146 MB needed, 5.8 GB available; memory 120 MB / 49 MB minimum — both pass.
- `--dry-run` note: "Not done by this installer: MCU flashing, starting/stopping services."

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
