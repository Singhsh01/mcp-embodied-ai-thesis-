# 01 — Static FR3 pick-and-place (named scene)

## Task ID & goal
**Task ID:** `01_static_pick_place`
**One-line goal:** Build a two-table physics scene from scratch, spawn an FR3, and have it pick a cube from table 1 and place it on table 2 using an RMPflow ScriptNode driven by `OnPlaybackTick`.

## Verbatim prompt sent to Claude
> Please use the Isaac MCP tool complete this: Create a physics scene with a ground plane, then spawn a Franka FR3 robot at the origin. Add two textured tables with a gap along Y. Place a small textured cube with physics enabled on top of the first table. Use `create_action_graph` to wire `OnPlaybackTick` → `ScriptNode`, and write a pick-and-place controller script using RMPflow for motion planning. Save the script to the `demo/` directory. Use `get_prim_info` to query actual positions and sizes of the tables and cube before writing the controller — do not hardcode coordinates. Start the simulation with Play. The robot should pick the cube from table 1 and place it on table 2. Verify the process using `step_simulation` with `observe_prims` on the cube to confirm it reaches table 2.

## Initial scene state
- **USD file:** none — empty stage at session start (`prim_count: 14`, only the Isaac Sim default lights/cameras).
- **Objects present:** none of the task objects.
- **Simulation state:** stopped.
- **Assets root:** `https://omniverse-content-production.s3-us-west-2.amazonaws.com/Assets/Isaac/5.1`.

## Success criteria
1. A `PhysicsScene` and ground plane exist.
2. A Franka FR3 (9 DOF: 7 arm + 2 fingers) spawned at origin.
3. Two static collider "tables" with a Y-axis gap, both with a textured material applied.
4. One dynamic rigid-body "cube" with a textured material, resting on table 1's top.
5. An `OmniGraph` with exactly two nodes — `OnPlaybackTick` and a `ScriptNode` — connected via `outputs:tick → inputs:execIn`.
6. Controller script saved under a `demo/` directory and referenced by the ScriptNode's `scriptPath`.
7. **No hardcoded coordinates in the controller**: all pick/place targets derived from values queried via `get_prim_info`.
8. After `play_simulation` and a sufficient number of `step_simulation` ticks, `observe_prims` on the cube shows it on table 2 with zero velocity (Y-coordinate flipped sign vs. start; Z back to resting height on table 2's top).

## Cross-references
- **Transcript:** `../orchestration_logs/01_static_pick_place.md`
- **Tool-call trace:** `../orchestration_logs/01_static_pick_place.jsonl`
- **Generated controller:** `../generated_scripts/01_static_pick_place_controller.py` (original) and `..._fixed.py` (FR3 preset + TCP frame fix)
- **Scoring:** `../evaluation_notes/01_static_pick_place.md`
- **Screenshots:** *(none captured during this run)*

## Video
FR3 Pick-and-Place Workflow  ![FR3 Pick and Place](../figures/ScreenRecording2026-05-14at8.27.48PM-ezgif.com-video-to-gif-converter.gif)
![FR3 Pick and Place](../../figures/fr3_pick_place.gif)

