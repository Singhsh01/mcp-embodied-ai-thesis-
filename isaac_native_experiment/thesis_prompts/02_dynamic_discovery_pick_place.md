# 02 — Dynamic-discovery pick-and-place

## Task ID & goal
**Task ID:** `02_dynamic_discovery_pick_place`
**One-line goal:** Without any hardcoded names or coordinates, inspect the running scene, infer movable cubes resting on tables, pick the closest cube to the robot, and place it on the farthest reachable table surface.

## Verbatim prompt sent to Claude
> Use the Isaac MCP tools to inspect the current scene.
>
> Identify all movable physics-enabled objects placed on tables.
> Create an Action Graph dynamically that:
> - continuously monitors the scene using OnPlaybackTick,
> - selects the closest movable cube to the robot,
> - generates a ScriptNode controller using RMPflow,
> - picks the object,
> - places it onto the farthest available table surface.
> Do not hardcode object names or coordinates.
> Use get_prim_info and scene queries to infer:
> - object transforms,
> - dimensions,
> - table surfaces,
> - and reachable placement positions.
> Start the simulation and verify the object's final location using observe_prims and step_simulation.

## Initial scene state
- **USD file:** in-memory stage carried over from task 01.
- **Objects present at task start:**
  - `/World/PhysicsScene`, `/World/groundPlane`
  - `/World/FrankaFR3` at (0, 0, 0)
  - `/World/Table1` at (0.5, −0.35, 0.2), `/World/Table2` at (0.5, +0.35, 0.2)
  - `/World/TargetCube` (red, 5 cm, dynamic) — last left on table 2 from task 01
  - The old `/World/PickPlaceGraph` action graph from task 01
  - Materials: `/World/Looks/WoodTable`, `/World/Looks/RedCube`
- **Simulation state:** paused after task 01; Claude stops the timeline before building anything new.

## Scene-augmentation actions Claude performed *inside* the task
To make the discovery problem non-trivial (otherwise "closest cube" and "farthest table" reduce to the only available pair), Claude:
- Deleted `/World/PickPlaceGraph` from task 01.
- Authored a fresh translate op on `/World/TargetCube` back to (0.5, −0.35, 0.425) on table 1.
- Added `/World/Table3` at (−0.45, 0.0, 0.2), 0.2 × 0.3 × 0.4 m, wood material.
- Added `/World/BlueCube` (6 cm dynamic cube) on table 2, with a new `/World/Looks/BlueCube` PBR material.

This is documented in the transcript so it doesn't pass as cheating: the controller still discovers everything at runtime.

## Success criteria
1. The controller never references any prim by hardcoded path or any coordinate as a literal.
2. The controller traverses the stage and correctly classifies:
   - the articulation root → FR3,
   - non-rigid-body collider prims under `/World` with a top face above ground → tables,
   - dynamic rigid bodies sitting on top of some table → movable cubes.
3. The controller selects the cube whose XY distance to the robot base is smallest.
4. The controller selects the table whose footprint center is farthest from that cube (excluding the table the cube currently sits on) **and** within the robot's reach radius.
5. A new `OmniGraph` is created with `OnPlaybackTick → ScriptNode`.
6. After `play_simulation`, `step_simulation` + `observe_prims` confirms the selected cube has moved from its source table to the chosen destination table (XY footprint match + Z back to resting height + zero velocity at steady state).

## Cross-references
- **Transcript:** `../orchestration_logs/02_dynamic_discovery_pick_place.md`
- **Tool-call trace:** `../orchestration_logs/02_dynamic_discovery_pick_place.jsonl`
- **Generated controller:** `../generated_scripts/02_dynamic_discovery_pick_place_controller.py`
- **Scoring:** `../evaluation_notes/02_dynamic_discovery_pick_place.md`
- **Screenshots:** *(none captured during this run)*
