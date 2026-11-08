#!/bin/bash
# Build the K1 Max host artifacts (c_helper.so and the Linux host MCU).
#
# Usage: CROSS_PREFIX=<triplet>- scripts/build-k1-host.sh
#
# Builds into the working tree only; nothing is deployed. The prefix is never
# guessed: the K1 Max host is 32-bit little-endian MIPS32r2 (o32, NAN2008,
# glibc 2.29), so every artifact's ELF header is verified before this script
# reports success.
set -eu

: "${CROSS_PREFIX:?CROSS_PREFIX is required, e.g. CROSS_PREFIX=mipsel-linux-}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
OUT_DIR="$ROOT/out/k1-host"
cd "$ROOT"

command -v "${CROSS_PREFIX}gcc" >/dev/null ||
    { echo "error: ${CROSS_PREFIX}gcc not found" >&2; exit 1; }

# Fail unless $1 is an ELF32 little-endian MIPS o32 NAN2008 object.
verify_elf() {
    python3 -I - "$1" <<'PY'
import struct, sys
path = sys.argv[1]
d = open(path, "rb").read(64)
ok = d[:4] == b"\x7fELF" and d[4] == 1 and d[5] == 1  # ELF32, little-endian
machine = struct.unpack("<H", d[18:20])[0]
flags = struct.unpack("<I", d[36:40])[0]
ok = ok and machine == 8                   # EM_MIPS
ok = ok and (flags & 0xF000) == 0x1000     # EF_MIPS_ABI_O32
ok = ok and bool(flags & 0x400)            # EF_MIPS_NAN2008
if not ok:
    sys.exit("%s: not ELF32 LE MIPS o32 NAN2008 (flags=0x%08x)" % (path, flags))
print("verified %s (flags=0x%08x)" % (path, flags))
PY
}

echo "== c_helper.so =="
make -C klippy/chelper clean
make -C klippy/chelper CROSS_PREFIX="$CROSS_PREFIX"
verify_elf klippy/chelper/c_helper.so

echo "== host MCU =="
mkdir -p "$OUT_DIR"
BUILD_CONFIG="$OUT_DIR/config.host"
cp .config.host "$BUILD_CONFIG"
make clean KCONFIG_CONFIG="$BUILD_CONFIG" OUT="$OUT_DIR/obj/"
make KCONFIG_CONFIG="$BUILD_CONFIG" OUT="$OUT_DIR/obj/" CROSS_PREFIX="$CROSS_PREFIX"
cp "$OUT_DIR/obj/klipper.elf" "$OUT_DIR/klipper_host_mcu"
verify_elf "$OUT_DIR/klipper_host_mcu"

sha256sum klippy/chelper/c_helper.so "$OUT_DIR/klipper_host_mcu" | tee "$OUT_DIR/SHA256SUMS"
