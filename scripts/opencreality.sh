#!/bin/sh
# opencreality - boot mode selector for the K1 Max (opencreality vs stock).
#
# Manages /usr/data/opencreality as the runtime root.  Service init scripts
# are installed under /etc/init.d/.  Stock service scripts are disabled by
# renaming to .disabled, restored when switching back to stock mode.
#
# Usage:
#   opencreality mode opencreality   - switch to Kalico/Moonraker/Fluidd
#   opencreality mode stock          - restore stock Klipper/Moonraker
#   opencreality status              - show current mode and service state
#
# Authorization: only 'mode' transitions write to /etc/init.d/ and
# /usr/data/opencreality/state.  Requires a reboot to take effect.
# Never flashes MCU firmware, changes networking, or stops running services.
#
# Service name prefixes:
#   Stock: S55klipper_service  S56moonraker_service  S57klipper_mcu
#   Ours:  S55oc_kalico        S56oc_moonraker       S57oc_web
#
# A transition:
#   1. Checks the installation (refuses if ours are missing).
#   2. Renames conflicting stock/ours scripts to .disabled / back.
#   3. Writes /usr/data/opencreality/state/mode.
#   4. Prints "Reboot required" — does not reboot automatically.
#
# NOTES:
# - /etc/init.d/ on the K1 is on the squashfs overlay; it is persistent.
# - This script runs as root (all K1 software does).
# - It does NOT manipulate running services (no start/stop/kill).  Changing
#   a running system requires a supervised reboot; see the deployment runbook.

set -u
INIT_D=/etc/init.d
OC_ROOT=/usr/data/opencreality
STATE=$OC_ROOT/state
MODE_FILE=$STATE/mode

# Stock scripts to disable when switching to opencreality mode.
# S99start_app is the Creality app watchdog; it re-enables disabled services.
STOCK_CONFLICT="S55klipper_service S57klipper_mcu S99start_app"
# Ours to enable/disable.
OC_SCRIPTS="S55oc_kalico S56oc_moonraker S57oc_web"

usage() {
    echo "Usage: opencreality mode {opencreality|stock}" >&2
    echo "       opencreality status" >&2
    exit 1
}

current_mode() {
    [ -f "$MODE_FILE" ] && cat "$MODE_FILE" || echo "unknown"
}

script_present() {
    [ -f "$INIT_D/$1" ]
}
script_disabled() {
    [ -f "$INIT_D/$1.disabled" ]
}

check_oc_installed() {
    for s in $OC_SCRIPTS; do
        script_present "$s" || script_disabled "$s" || {
            echo "REFUSED: opencreality service $s is missing from $INIT_D" >&2
            echo "Run the opencreality installer first." >&2
            exit 1
        }
    done
}

do_mode_opencreality() {
    check_oc_installed
    # Disable stock conflicting scripts.
    for s in $STOCK_CONFLICT; do
        if script_present "$s"; then
            mv "$INIT_D/$s" "$INIT_D/$s.disabled"
            echo "disabled: $s"
        fi
    done
    # Enable our scripts (rename back from .disabled if needed).
    for s in $OC_SCRIPTS; do
        if script_disabled "$s"; then
            mv "$INIT_D/$s.disabled" "$INIT_D/$s"
            echo "enabled:  $s"
        elif script_present "$s"; then
            echo "already enabled: $s"
        fi
    done
    mkdir -p "$STATE"
    printf 'opencreality\n' > "$MODE_FILE"
    echo "Mode set to opencreality. Reboot to apply."
}

do_mode_stock() {
    # Disable our scripts.
    for s in $OC_SCRIPTS; do
        if script_present "$s"; then
            mv "$INIT_D/$s" "$INIT_D/$s.disabled"
            echo "disabled: $s"
        fi
    done
    # Restore stock scripts.
    for s in $STOCK_CONFLICT; do
        if script_disabled "$s"; then
            mv "$INIT_D/$s.disabled" "$INIT_D/$s"
            echo "restored: $s"
        elif script_present "$s"; then
            echo "already present: $s"
        fi
    done
    mkdir -p "$STATE"
    printf 'stock\n' > "$MODE_FILE"
    echo "Mode set to stock. Reboot to apply."
}

do_status() {
    MODE=$(current_mode)
    echo "Current mode: $MODE"
    echo ""
    echo "Init scripts:"
    for s in $STOCK_CONFLICT $OC_SCRIPTS; do
        if script_present "$s"; then
            echo "  [enabled]  $s"
        elif script_disabled "$s"; then
            echo "  [disabled] $s"
        else
            echo "  [absent]   $s"
        fi
    done
    echo ""
    echo "Runtime:"
    for name in kalico moonraker nginx; do
        pid=$(pidof "$name" 2>/dev/null || true)
        if [ -n "$pid" ]; then
            echo "  running: $name (pid $pid)"
        else
            echo "  stopped: $name"
        fi
    done
    # Klippy and moonraker show as python3/python, so check by cmdline
    for label in "klippy.py" "moonraker.py"; do
        pids=$(grep -l "$label" /proc/*/cmdline 2>/dev/null | sed 's|/proc/||;s|/cmdline||' | tr '\n' ' ')
        if [ -n "$pids" ]; then
            echo "  running: $label (pids: $pids)"
        fi
    done
}

[ $# -ge 1 ] || usage
CMD=$1; shift

case "$CMD" in
    mode)
        [ $# -eq 1 ] || usage
        case "$1" in
            opencreality) do_mode_opencreality;;
            stock)        do_mode_stock;;
            *)            echo "Unknown mode: $1 (use 'opencreality' or 'stock')" >&2; exit 1;;
        esac
        ;;
    status)
        do_status
        ;;
    *)
        usage
        ;;
esac
