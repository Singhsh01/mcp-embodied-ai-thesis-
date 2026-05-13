#!/usr/bin/env bash
# =============================================================================
# reorganize.sh
#
# One-shot reorganizer for the Master Thesis workspace.
# Run this from inside the "Master Thesis" folder:
#
#     cd ~/Downloads/"Master Thesis"
#     bash reorganize.sh            # apply changes
#     bash reorganize.sh --dry-run  # preview, change nothing
#
# What it does
# -------------
#   1. Confirms the expected upstream folders are present.
#   2. Moves   isaacsim-mcp-server-main/  ->  isaac_native_experiment/isaacsim-mcp-server-main/
#   3. Copies  ros-mcp-server-main/examples/3_limo_mobile_robot/isaac_sim/
#               ->  ros_middleware_experiment/original_limo_example/
#   4. Copies  the ROS-MCP server CORE files
#               ->  ros_middleware_experiment/ros_mcp_server/
#      (server.py, ros_mcp/, launch/, robot_specifications/, config/,
#       pyproject.toml, uv.lock, server.json, LICENSE, MANIFEST.in, README.md)
#   5. Deletes the original isaacsim-mcp-server-main/ and ros-mcp-server-main/
#      from the workspace root.
#   6. Prunes obvious cache / build folders (__pycache__, .pytest_cache, etc.)
#      from the new locations.
#
# It is safe to re-run: every step is guarded with -e tests.
# =============================================================================

set -euo pipefail

# ----- arg parsing -----------------------------------------------------------
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY_RUN=1 ;;
    -h|--help)
      sed -n '2,30p' "$0"; exit 0 ;;
    *) echo "Unknown argument: $arg"; exit 2 ;;
  esac
done

# ----- helpers ---------------------------------------------------------------
run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY-RUN \$ $*"
  else
    echo "       \$ $*"
    eval "$@"
  fi
}

note()  { printf "\n\033[1;34m== %s ==\033[0m\n" "$*"; }
warn()  { printf "\033[1;33m!!  %s\033[0m\n" "$*"; }
err()   { printf "\033[1;31mERR %s\033[0m\n" "$*" >&2; }

# ----- sanity ----------------------------------------------------------------
ROOT="$(pwd)"
note "Reorganizing workspace at: $ROOT"

if [[ ! -d "isaacsim-mcp-server-main" ]] && [[ ! -d "isaac_native_experiment/isaacsim-mcp-server-main" ]]; then
  warn "isaacsim-mcp-server-main/ not found at the workspace root and not yet moved. Skipping Isaac native step."
fi

if [[ ! -d "ros-mcp-server-main" ]] && [[ ! -d "ros_middleware_experiment/ros_mcp_server" ]]; then
  warn "ros-mcp-server-main/ not found at the workspace root and ros_mcp_server/ not yet present. Skipping ROS step."
fi

# ----- 1. Move Isaac Sim MCP server ------------------------------------------
note "Step 1 — Move isaacsim-mcp-server-main into isaac_native_experiment/"

if [[ -d "isaacsim-mcp-server-main" ]]; then
  if [[ -d "isaac_native_experiment/isaacsim-mcp-server-main" ]]; then
    warn "Destination isaac_native_experiment/isaacsim-mcp-server-main/ already exists. Skipping move."
  else
    run "mkdir -p isaac_native_experiment"
    run "mv 'isaacsim-mcp-server-main' 'isaac_native_experiment/isaacsim-mcp-server-main'"
  fi
else
  echo "  (already moved or absent)"
fi

# ----- 2. Extract the limo Isaac Sim example ---------------------------------
note "Step 2 — Extract limo Isaac Sim example into ros_middleware_experiment/original_limo_example/"

LIMO_SRC="ros-mcp-server-main/examples/3_limo_mobile_robot/isaac_sim"
LIMO_DST="ros_middleware_experiment/original_limo_example"

if [[ -d "$LIMO_SRC" ]]; then
  if [[ -d "$LIMO_DST" ]]; then
    warn "Destination $LIMO_DST/ already exists. Skipping copy."
  else
    run "mkdir -p '$LIMO_DST'"
    # copy with preserved attributes; -a handles binary USD files correctly
    run "cp -a '$LIMO_SRC/.' '$LIMO_DST/'"
  fi
else
  echo "  (limo source not found — already extracted, or the upstream layout differs)"
fi

# ----- 3. Copy ROS-MCP server CORE into ros_mcp_server/ ----------------------
note "Step 3 — Copy ROS-MCP server core into ros_middleware_experiment/ros_mcp_server/"

ROS_SRC="ros-mcp-server-main"
ROS_DST="ros_middleware_experiment/ros_mcp_server"

if [[ -d "$ROS_SRC" ]]; then
  if [[ -d "$ROS_DST" ]]; then
    warn "Destination $ROS_DST/ already exists. Skipping copy."
  else
    run "mkdir -p '$ROS_DST'"
    # Files we need to keep so the limo example is actually runnable.
    # (Everything else — examples/, tests/, docs/ — is intentionally dropped.)
    CORE_PATHS=(
      "server.py"
      "server.json"
      "pyproject.toml"
      "uv.lock"
      "LICENSE"
      "MANIFEST.in"
      "README.md"
      "ros_mcp"
      "launch"
      "robot_specifications"
      "config"
    )
    for p in "${CORE_PATHS[@]}"; do
      if [[ -e "$ROS_SRC/$p" ]]; then
        run "cp -a '$ROS_SRC/$p' '$ROS_DST/'"
      else
        warn "  upstream is missing $ROS_SRC/$p (skipped)"
      fi
    done

    # Save a short note documenting WHERE this came from and WHAT was dropped.
    if [[ "$DRY_RUN" -eq 0 ]]; then
      cat > "$ROS_DST/PROVENANCE.md" <<'EOF'
# Provenance

These files were extracted from the upstream **ros-mcp-server** project to make the
limo Isaac Sim example reproducible inside this thesis workspace.

Kept:
- server.py, server.json, pyproject.toml, uv.lock, MANIFEST.in, LICENSE, README.md
- ros_mcp/          (the importable package)
- launch/           (rosbridge + MCP server launch helpers)
- robot_specifications/  (YAML robot specs incl. local_rosbridge.yaml)
- config/           (MCP client config templates)

Intentionally dropped (not needed for the thesis experiments):
- examples/        (only 3_limo_mobile_robot/isaac_sim is kept, as ../original_limo_example/)
- tests/           (CI tests, Docker integration tests)
- docs/            (full upstream documentation site)

All copyright and licensing remains with the upstream authors; see ./LICENSE.
EOF
      echo "       wrote $ROS_DST/PROVENANCE.md"
    fi
  fi
else
  echo "  (ros-mcp-server-main not found — already extracted, or upstream absent)"
fi

# ----- 4. Delete originals ---------------------------------------------------
note "Step 4 — Delete original top-level repo folders"

# Only delete after we've successfully relocated content.
if [[ -d "isaacsim-mcp-server-main" ]] && [[ -d "isaac_native_experiment/isaacsim-mcp-server-main" ]]; then
  # This branch only fires if Step 1 was skipped due to existing dest — the source
  # is then redundant and safe to remove.
  run "rm -rf 'isaacsim-mcp-server-main'"
fi

if [[ -d "ros-mcp-server-main" ]] && [[ -d "ros_middleware_experiment/original_limo_example" ]] && [[ -d "ros_middleware_experiment/ros_mcp_server" ]]; then
  run "rm -rf 'ros-mcp-server-main'"
fi

# ----- 5. Prune caches in the new locations ----------------------------------
note "Step 5 — Prune build/cache folders inside the new layout"

PRUNE_PATTERNS=(
  "__pycache__"
  ".pytest_cache"
  ".mypy_cache"
  ".ruff_cache"
  ".tox"
  ".coverage"
  "htmlcov"
  "*.egg-info"
  ".uv-cache"
  "node_modules"
  "build"
  "install"
  "log"
  ".colcon"
)

for target in "isaac_native_experiment" "ros_middleware_experiment"; do
  if [[ -d "$target" ]]; then
    for pattern in "${PRUNE_PATTERNS[@]}"; do
      # -prune is fine because we want to skip diving into matched dirs.
      while IFS= read -r -d '' hit; do
        run "rm -rf '$hit'"
      done < <(find "$target" -name "$pattern" -print0 2>/dev/null || true)
    done
  fi
done

# ----- 6. Final summary ------------------------------------------------------
note "Done."
echo "Final top-level layout:"
ls -1 .
echo
echo "If --dry-run was used, no files were modified."
