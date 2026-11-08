# K1 Max deployment runbook

This document describes a future deployment only. The preparation work did not deploy files, restart services, reboot the printer, change networking, flash an MCU, heat, or move the printer.

## Preconditions

- Work from branch `k1_max_kalico` after verifying the repository root, branch, and status.
- Keep the read-only backup at `/home/thijs/k1max-backups/k1max-20261107-183834` and verify its SHA-256 manifest.
- Keep a second recovery path available before any printer write: physical access plus a verified vendor recovery image or serial procedure. The existing OTA filename is evidence that an image exists, not proof that it is a usable recovery image.
- Do not use the fork's `mcu0`, `nozzle`, or `bed` binaries on this printer. Their extracted protocol dictionaries differ from the installed vendor MCU dictionaries.
- Do not proceed until `prtouch_v2`, its native wrappers, `bl24c16f`, `fan_feedback`, and `custom_macro` have a reviewed Kalico implementation or an explicitly tested vendor-compatible integration.
- Do not proceed until an ELF32 little-endian MIPS32r2/o32/NAN2008 toolchain and a compatible glibc/sysroot are pinned and the offline build passes.

## Staged deployment proposal

1. **Stage locally.** Build the host MCU and `c_helper.so` into an ignored output directory. Record source revision, toolchain version, ELF headers, checksums, and dependency versions. Load the copied printer configuration in an offline test harness; do not use live serial devices.
2. **Back up again.** With read-only SSH, capture the current service definitions, host Klipper tree, configuration, logs, firmware metadata, and a fresh checksum manifest. Confirm the restore files are readable before any write.
3. **Prepare a reversible host-only change.** Copy the new host files to a temporary printer path only after a separate deployment approval. Preserve the vendor host binary and service command. Do not overwrite MCU firmware or physical-MCU files.
4. **Switch the host service only with approval.** Stop the vendor Klipper host service, start the staged Kalico host with the existing service supervisor, and watch the log. If any MCU protocol error, missing module, invalid sensor, or unsafe configuration appears, stop and restore the vendor host service.
5. **Validate idle state.** Require all configured MCUs to connect, plausible temperatures, working emergency stop handling, correct limits, and a `ready` state without enabling heaters or motors. A successful process start is not sufficient.
6. **Validate Moonraker and Fluidd.** Confirm `/server/info` reports the expected Klippy state and that Fluidd loads. Replace broad LAN trust with authenticated access or the narrowest intended LAN policy before exposing the service beyond the test client.
7. **Test persistence.** Only after a separate reboot approval, verify Wi-Fi, supervisor ordering, Klippy, Moonraker, Fluidd, and the camera after a cold boot. Keep the recovery path active.
8. **Run physical tests last.** First test emergency stop and output-off behavior. Then perform supervised fan checks, sensor checks, low-temperature heater tests, homing, probing, and motion one capability at a time. Never bypass probe, homing, thermal-runaway, max/min temperature, or endstop protections to reach `ready`.

## Rollback

- Stop the staged Kalico host service only with approval.
- Restore the vendor service command and vendor host binary from the verified backup.
- Restore the original configuration and service files if they were changed.
- Restart the vendor service only with approval, then verify Moonraker reports the original vendor Klippy version.
- If the host cannot start, use the pre-confirmed physical or serial recovery method. Do not flash an unverified MCU image.
- Record the failure, exact log evidence, checksums, and remaining incompatibility. Do not retry a deployment after an unexplained MCU protocol or safety fault.

## Explicitly unresolved

- The installed vendor MCU dictionaries contain Creality-specific `prtouch`, `fancheck`, `dirzctl`, and HX711S commands that are absent from the fork's K1 MCU binaries.
- The current Kalico tree does not include the vendor `prtouch_v2` implementation or wrappers.
- The current branch has preparation support for the MIPS host, but no verified little-endian MIPS compiler/sysroot has been installed or used.
- No deployment decision is implied by this runbook.
