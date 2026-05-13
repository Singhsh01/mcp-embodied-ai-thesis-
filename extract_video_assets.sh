#!/usr/bin/env bash
# =============================================================================
# extract_video_assets.sh
#
# Reads the uploaded experiment videos from your Claude Desktop "uploads"
# folder, extracts five key frames + a contact sheet + a short looping GIF
# per video, and drops everything into the correct screenshots subfolder
# inside the Master Thesis workspace.
#
# Usage:
#     cd ~/Downloads/"Master Thesis"
#     bash extract_video_assets.sh                   # apply
#     bash extract_video_assets.sh --dry-run         # preview, change nothing
#     bash extract_video_assets.sh --uploads PATH    # override uploads dir
#
# Requirements:
#     - ffmpeg + ffprobe (install on macOS:  brew install ffmpeg)
#
# Idempotent: re-running overwrites existing assets in place.
# =============================================================================

set -euo pipefail

# ----- defaults --------------------------------------------------------------
ROOT="$(cd "$(dirname "$0")" && pwd)"
UPLOADS_DEFAULT="$HOME/Library/Application Support/Claude/local-agent-mode-sessions/0dcaafcb-a122-41a9-9e42-315c24348c56/7c61949f-ef86-4841-b761-e43b34312bd8/local_7fc68fe9-df3f-4d67-b077-9041946dd876/uploads"
UPLOADS="$UPLOADS_DEFAULT"
DRY=0

# ----- arg parsing -----------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run|-n) DRY=1; shift ;;
    --uploads)    UPLOADS="$2"; shift 2 ;;
    -h|--help)    sed -n '2,22p' "$0"; exit 0 ;;
    *) echo "Unknown arg: $1"; exit 2 ;;
  esac
done

# ----- preflight -------------------------------------------------------------
note() { printf "\n\033[1;34m== %s ==\033[0m\n" "$*"; }
warn() { printf "\033[1;33m!!  %s\033[0m\n" "$*"; }
err()  { printf "\033[1;31mERR %s\033[0m\n" "$*" >&2; }

run() {
  if [[ "$DRY" -eq 1 ]]; then
    printf "DRY  %s\n" "$*"
  else
    printf "  \$ %s\n" "$*"
    eval "$@"
  fi
}

note "extract_video_assets.sh"
echo "Workspace : $ROOT"
echo "Uploads   : $UPLOADS"

command -v ffmpeg  >/dev/null 2>&1 || { err "ffmpeg not found. Install with:  brew install ffmpeg"; exit 1; }
command -v ffprobe >/dev/null 2>&1 || { err "ffprobe not found. Install with:  brew install ffmpeg"; exit 1; }
[[ -d "$UPLOADS" ]] || { err "Uploads folder not found: $UPLOADS"; exit 1; }

# ----- destination root setup ------------------------------------------------
ISAAC_SCR="$ROOT/isaac_native_experiment/screenshots"
ROS_SCR="$ROOT/ros_middleware_experiment/screenshots"

mkdir -p "$ISAAC_SCR" "$ROS_SCR"

# ----- core extraction routine ----------------------------------------------
# extract_one  <src_video_path>  <dst_dir>  <label_for_overlay>
extract_one() {
  local SRC="$1"
  local DST="$2"
  local LABEL="$3"

  if [[ ! -f "$SRC" ]]; then
    warn "Source missing, skipping: $SRC"
    return 0
  fi

  note "→ $LABEL"
  echo "   src : $SRC"
  echo "   dst : $DST"

  run "mkdir -p '$DST'"

  # Probe duration in seconds (float).
  local DUR
  DUR=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$SRC")
  if [[ -z "$DUR" ]] || awk "BEGIN{exit !($DUR <= 0)}"; then
    warn "   could not determine duration, skipping ($SRC)"
    return 0
  fi
  echo "   duration: ${DUR}s"

  # Pick five timestamps. Clamp the end frame back ~0.2s so we don't fall off.
  local T0 T25 T50 T75 T99
  T0=$(awk "BEGIN{printf \"%.3f\", 0}")
  T25=$(awk "BEGIN{printf \"%.3f\", $DUR*0.25}")
  T50=$(awk "BEGIN{printf \"%.3f\", $DUR*0.50}")
  T75=$(awk "BEGIN{printf \"%.3f\", $DUR*0.75}")
  T99=$(awk "BEGIN{printf \"%.3f\", ($DUR>0.4)?$DUR-0.2:$DUR}")

  # Extract PNG frames (longest edge 1280px for thesis use).
  for pair in "00_start:$T0" "25_quarter:$T25" "50_half:$T50" "75_threequarter:$T75" "99_end:$T99"; do
    local NAME="${pair%%:*}"
    local TS="${pair##*:}"
    local OUT="$DST/frame_${NAME}.png"
    run "ffmpeg -y -loglevel error -ss $TS -i \"$SRC\" -frames:v 1 -vf 'scale=1280:-2:flags=lanczos' \"$OUT\""
  done

  # Contact sheet: 5 tiles in a 5x1 strip, then re-encode to PNG @ 1600px wide.
  local TILE_DIR="$DST/.tiles"
  run "mkdir -p '$TILE_DIR'"
  local i=0
  for nm in 00_start 25_quarter 50_half 75_threequarter 99_end; do
    i=$((i+1))
    run "cp '$DST/frame_${nm}.png' '$TILE_DIR/$(printf %02d $i).png'"
  done
  run "ffmpeg -y -loglevel error -pattern_type glob -i '$TILE_DIR/*.png' -filter_complex 'tile=5x1:margin=8:padding=8' '$DST/contact_sheet.png'"
  run "rm -rf '$TILE_DIR'"

  # Looping preview GIF: take the middle portion (up to 6s) at 480px wide, 12fps.
  # Start window biased toward the middle so the GIF shows the interesting bit.
  local GIF_START GIF_LEN
  GIF_LEN=$(awk "BEGIN{ d=$DUR; printf \"%.3f\", (d<6)?d:6 }")
  GIF_START=$(awk "BEGIN{ d=$DUR; l=$GIF_LEN; s=(d-l)/2; if(s<0)s=0; printf \"%.3f\", s }")
  local PAL="$DST/.palette.png"
  run "ffmpeg -y -loglevel error -ss $GIF_START -t $GIF_LEN -i \"$SRC\" -vf 'fps=12,scale=480:-2:flags=lanczos,palettegen=stats_mode=diff' \"$PAL\""
  run "ffmpeg -y -loglevel error -ss $GIF_START -t $GIF_LEN -i \"$SRC\" -i \"$PAL\" -lavfi 'fps=12,scale=480:-2:flags=lanczos [v]; [v][1:v] paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle' -loop 0 \"$DST/preview.gif\""
  run "rm -f '$PAL'"

  # Per-folder README, regenerated each run.
  if [[ "$DRY" -eq 0 ]]; then
    cat > "$DST/README.md" <<EOF
# $LABEL — extracted assets

Source video: \`$SRC\`
Approximate duration: ${DUR}s
Extraction: \`extract_video_assets.sh\`

## Frames

| Position | File |
| -------- | ---- |
| Start (0%) | \`frame_00_start.png\` |
| 25% | \`frame_25_quarter.png\` |
| 50% | \`frame_50_half.png\` |
| 75% | \`frame_75_threequarter.png\` |
| End (~100%) | \`frame_99_end.png\` |

## Composite

- \`contact_sheet.png\` — 5-tile strip suitable for a single thesis figure.
- \`preview.gif\` — short looping clip (~${GIF_LEN}s @ 480p) for inline embedding.

## Where to cite this in the thesis

- **Thesis body**: pick the most informative single frame (typically \`frame_50_half.png\` or \`frame_75_threequarter.png\`) and the \`contact_sheet.png\`.
- **Appendix**: include all five frames and the GIF.
- **Supplementary**: link the original source video (do **not** commit the source itself; it is gitignored).
EOF
    echo "   wrote README.md"
  fi
}

# ----- video → destination mapping ------------------------------------------
note "Mapping videos to destinations"

# Simulation-native (Isaac Sim) experiment — Task prompt runs
extract_one "$UPLOADS/Task 1.webm" "$ISAAC_SCR/task_01" "Task 1 — Isaac Sim native experiment"
extract_one "$UPLOADS/Task 2.webm" "$ISAAC_SCR/task_02" "Task 2 — Isaac Sim native experiment"
extract_one "$UPLOADS/Task 3.webm" "$ISAAC_SCR/task_03" "Task 3 — Isaac Sim native experiment"
extract_one "$UPLOADS/Task 5.webm" "$ISAAC_SCR/task_05" "Task 5 — Isaac Sim native experiment"

# Simulation-native (Isaac Sim) experiment — Franka pick-and-place repeatability runs
extract_one "$UPLOADS/Frankapickand place1.mp4" "$ISAAC_SCR/franka_pick_place_01" "Franka pick-and-place — run 1"
extract_one "$UPLOADS/Frankapickand place2.mp4" "$ISAAC_SCR/franka_pick_place_02" "Franka pick-and-place — run 2"
extract_one "$UPLOADS/Frankapickand place3.mp4" "$ISAAC_SCR/franka_pick_place_03" "Franka pick-and-place — run 3"
extract_one "$UPLOADS/Frankapickand place4.mp4" "$ISAAC_SCR/franka_pick_place_04" "Franka pick-and-place — run 4"
extract_one "$UPLOADS/Frankapickand place5.mp4" "$ISAAC_SCR/franka_pick_place_05" "Franka pick-and-place — run 5"

# Middleware-centric (ROS-MCP + LIMO) experiment — overview clip
extract_one "$UPLOADS/Untitled design.mp4" "$ROS_SCR/limo_overview" "LIMO overview clip (Untitled design.mp4) — ROS middleware experiment"

# ----- index pages -----------------------------------------------------------
note "Writing index pages"

if [[ "$DRY" -eq 0 ]]; then
  cat > "$ROS_SCR/INDEX.md" <<'EOF'
# ros_middleware_experiment / screenshots — index

The middleware-centric (ROS-MCP + rosbridge + LIMO) experiment is documented here.

| Folder | Source video | What it shows |
| ------ | ------------ | ------------- |
| `limo_overview/` | `uploads/Untitled design.mp4` | LIMO scene driven through the ROS-MCP middleware pipeline in Isaac Sim. Figure context for the middleware experiment chapter. |

> Note: the four `Task N.webm` recordings (Task 1, 2, 3, 5) belong to the **simulation-native** experiment. They live under `../../isaac_native_experiment/screenshots/task_0N/`.

Each subfolder contains 5 keyframes, a `contact_sheet.png`, a `preview.gif`, and its own README.
EOF

  cat > "$ISAAC_SCR/INDEX.md" <<'EOF'
# isaac_native_experiment / screenshots — index

All recordings of the simulation-native (Isaac Sim MCP) experiment live here. There are two recording campaigns.

## Task prompt runs

| Folder | Source video | What it shows |
| ------ | ------------ | ------------- |
| `task_01/` | `uploads/Task 1.webm` | Task 1 prompt run, driven by the Isaac Sim MCP server. |
| `task_02/` | `uploads/Task 2.webm` | Task 2 prompt run. |
| `task_03/` | `uploads/Task 3.webm` | Task 3 prompt run. |
| `task_05/` | `uploads/Task 5.webm` | Task 5 prompt run. (No Task 4 recording was uploaded.) |

## Franka pick-and-place — repeatability study

| Folder | Source video | What it shows |
| ------ | ------------ | ------------- |
| `franka_pick_place_01/` | `uploads/Frankapickand place1.mp4` | Run 1. |
| `franka_pick_place_02/` | `uploads/Frankapickand place2.mp4` | Run 2. |
| `franka_pick_place_03/` | `uploads/Frankapickand place3.mp4` | Run 3. |
| `franka_pick_place_04/` | `uploads/Frankapickand place4.mp4` | Run 4. |
| `franka_pick_place_05/` | `uploads/Frankapickand place5.mp4` | Run 5. |

Each subfolder contains 5 keyframes, a `contact_sheet.png`, a `preview.gif`, and its own README.

The five Franka runs are useful for the thesis as: (a) showing repeatability of the simulation-native pipeline across runs, (b) documenting any failure-mode variance, and (c) supplying the contact sheets that go into the qualitative-evaluation figure.
EOF
fi

note "Done."
echo "Open these to spot-check the output:"
echo "  $ROS_SCR/INDEX.md"
echo "  $ISAAC_SCR/INDEX.md"
