# 03 — Connection check, lighting, workspace camera

## Task ID & goal
**Task ID:** `03_connection_lights_camera`
**One-line goal:** Verify the MCP connection to Isaac Sim, create a physics scene if the stage is empty, install strong lighting, and place a camera that looks at the workspace.

## Verbatim prompt sent to Claude
> Check the connection with get_scene_info. If the scene is empty, create a physics scene.
> Add stronger lighting and place a camera that looks at the workspace.

## Initial scene state
- **USD file:** none — fresh stage at session start.
- **Objects present:** 14 prims, but all of them are Kit defaults (editor cameras under `/OmniverseKit_Persp` etc. + empty `/World` and `/Environment` xforms). No physics scene, no lights, no user content.
- **Simulation state:** stopped.
- **Assets root:** Isaac Sim 5.1 asset bundle.

## Success criteria
1. `get_scene_info` returns a `success` status confirming the MCP connection.
2. A `PhysicsScene` exists at `/World/PhysicsScene` with a ground plane.
3. At least two light prims are authored (one ambient/fill, one directional/key) with intensities meaningfully above scene defaults.
4. A camera prim exists with a pose that aims it at the workspace origin region.
5. No tool calls return errors.

## Cross-references
- **Transcript:** `../orchestration_logs/03_connection_lights_camera.md`
- **Tool-call trace:** `../orchestration_logs/03_connection_lights_camera.jsonl`
- **Generated scripts:** *(none — all work was direct MCP tool calls, no Python authored)*
- **Scoring:** `../evaluation_notes/03_connection_lights_camera.md`
- **Screenshots:** *(none captured during this task)*
