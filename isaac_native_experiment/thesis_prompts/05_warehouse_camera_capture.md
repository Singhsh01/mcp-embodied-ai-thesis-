# 05 — Warehouse environment + camera + capture

## Task ID & goal
**Task ID:** `05_warehouse_camera_capture`
**One-line goal:** Load a warehouse-like environment around the existing robots, position a new camera to frame them, and capture a still image.

## Verbatim prompt sent to Claude
> List available environments, choose a warehouse-like one, and load it.
> Create a camera and capture an image.

## Initial scene state
- **USD file:** in-memory stage carried over from tasks 03 + 04.
- **Objects present at task start:**
  - Physics scene + ground plane, dome + key lights
  - `/World/WorkspaceCamera` at `[2, -2, 1.5]`
  - `/World/Franka_1`, `/World/Franka_2`, `/World/Franka_3` at `[0,0,0]`, `[2,0,0]`, `[4,0,0]`
  - `/World/Go1` at `[1, 3, 0]`
- **Simulation state:** stopped.

## Success criteria
1. The agent lists available environment assets and picks one whose description matches "warehouse-like".
2. The environment is referenced into the stage so the robots appear inside it.
3. A new camera prim is authored at a pose that frames the robots-in-warehouse scene.
4. An image file is produced and the agent can confirm it shows real rendered pixels of the scene.

## Cross-references
- **Transcript:** `../orchestration_logs/05_warehouse_camera_capture.md`
- **Tool-call trace:** `../orchestration_logs/05_warehouse_camera_capture.jsonl`
- **Generated scripts:** `../generated_scripts/05_warehouse_camera_capture_capture_helper.py`
- **Scoring:** `../evaluation_notes/05_warehouse_camera_capture.md`
