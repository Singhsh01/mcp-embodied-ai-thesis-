#!/usr/bin/env bash
# =============================================================================
# fix_screenshot_layout.sh
#
# Tasks 1, 2, 3, 5 were originally extracted into
#   ros_middleware_experiment/screenshots/task_NN/
# but they actually belong to the simulation-native (Isaac Sim) experiment.
# This script moves them to
#   isaac_native_experiment/screenshots/task_NN/
#
# limo_overview/ stays where it is (correct).
# franka_pick_place_NN/ stay where they are (correct).
#
# Idempotent. Run from the Master Thesis folder:
#     cd ~/Downloads/"Master Thesis"
#     bash fix_screenshot_layout.sh            # apply
#     bash fix_screenshot_layout.sh --dry-run  # preview
# =============================================================================

set -euo pipefail

DRY=0
for a in "$@"; do
  case "$a" in
    --dry-run|-n) DRY=1 ;;
    -h|--help) sed -n '2,18p' "$0"; exit 0 ;;
    *) echo "Unknown arg: $a"; exit 2 ;;
  esac
done

ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC="$ROOT/ros_middleware_experiment/screenshots"
DST="$ROOT/isaac_native_experiment/screenshots"

run() {
  if [[ "$DRY" -eq 1 ]]; then echo "DRY  $*"; else echo "  \$ $*"; eval "$@"; fi
}

echo "== Fix screenshot layout =="
echo "src : $SRC"
echo "dst : $DST"

run "mkdir -p '$DST'"

for n in 01 02 03 05; do
  if [[ -d "$SRC/task_$n" ]]; then
    if [[ -d "$DST/task_$n" ]]; then
      echo "  ! '$DST/task_$n' already exists — skipping move of '$SRC/task_$n'"
    else
      run "mv '$SRC/task_$n' '$DST/task_$n'"
    fi
  else
    echo "  (no '$SRC/task_$n' — already moved or never present)"
  fi
done

echo
echo "Final layout:"
echo "  isaac_native_experiment/screenshots/"
ls -1 "$DST" 2>/dev/null | sed 's/^/    /'
echo "  ros_middleware_experiment/screenshots/"
ls -1 "$SRC" 2>/dev/null | sed 's/^/    /'
