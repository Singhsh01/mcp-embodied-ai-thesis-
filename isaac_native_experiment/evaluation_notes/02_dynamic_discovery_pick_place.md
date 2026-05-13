# 02 — Dynamic-discovery pick-and-place — evaluation

| Field | Value |
| --- | --- |
| Task ID | `02_dynamic_discovery_pick_place` |
| Outcome | **partial** |
| Number of tool calls | **12 executed** (+ 3 documented as not-executed before the chat ended) |
| Self-corrections | **0** during this task — the agent applied the lessons from task 01 preemptively (host-side file transfer; controller designed to detect FR3 preset by joint prefix; no naive translate-op resets while sim is running) |
| Failure modes (if any) | None observed during execution. The run is incomplete because the chat terminated immediately after the file transfer to `/home/sing/demo/dynamic_pick_and_place.py`, *before* the action graph could be rebuilt and stepped. This is an evaluation cut-off, not an agent failure. |
| Notable observations | See below. |

## Why "partial" and not "success"
The deliverable splits into two halves: (a) **author** a controller that correctly discovers the scene without hardcoded names/coordinates, and (b) **run** the controller end-to-end and observe the cube on the chosen destination table. Half (a) is unambiguously complete and is auditable from `../generated_scripts/02_dynamic_discovery_pick_place_controller.py`. Half (b) was not reached. The transcript marks turns 13–15 as "not_executed" and explains why: the chat ended.

The discovery logic was statically reasoned about against the known stage and produces a falsifiable prediction (red cube ends on Table3 at (−0.45, 0)). A future evaluator can resume from the captured `/home/sing/demo/dynamic_pick_and_place.py` and execute exactly three more tool calls — re-author ScriptNode inputs via `Usd.Attribute.Set`, `play_simulation`, `step_simulation(~500, observe_prims=[/World/TargetCube])` — to convert this to a hard success or hard failure.

## What was elegant
- The discovery is built on **USD/UsdPhysics API checks**, not name heuristics. Tables are `CollisionAPI ∧ ¬RigidBodyAPI ∧ top_z > 0.1 m`. Movable cubes are `RigidBodyAPI ∧ ¬kinematic ∧ supported-by-a-table`. The robot is `ArticulationRootAPI`. These rules survive renaming, prim restructuring, and material/USD-reference changes.
- "Supported by table T" uses both XY footprint containment *and* a Z-gap window (`0 ≤ cube.z − T.top_z ≤ 0.2`), so a cube falling between two adjacent tables wouldn't be miscategorized.
- The reach-radius guard (`0.85 m` default) excludes a table the FR3 can see but can't reach. This wasn't asked for in the prompt; the agent inferred it because the third table sat almost at the limit of the FR3's workspace.
- The motion-init code generalizes the lesson from task 01: preset selection is driven by `dof_names[0].split("_")[0]` with a small mapping table, so swapping in a Panda would work with no further edits.

## What was brittle (anticipated)
- The reach-radius `0.85` is itself an unmotivated number. It's calibrated for the FR3 but isn't queried from the robot description. A future iteration should compute it from the manipulator's URDF (sum of link lengths) or from a self-test ping of RMPflow's IK reachability.
- The "table" heuristic excludes anything under `/World/` whose top is below 0.1 m. Shelves taller than 0.1 m that are *not* meant for placement (cabinet sides, walls) would be miscategorized. A more principled filter would require flat top-face normals and a minimum top-face area.
- "Closest cube to robot" uses XY only. For shelving with multiple z-levels, 3-D distance to the EE workspace centroid would be more honest.

## What surprised me
- The agent **proactively augmented the scene** (3rd table + 2nd cube) before writing the controller, *and* documented the augmentation in-line so the test isn't degenerate. This is exactly the right experimental discipline; many agent runs would have just answered the trivial 1-cube/2-table case.
- The agent's static analysis of the not-yet-run controller (see transcript, "Static analysis…" section) predicted the cube would end on **Table3** rather than the more "obvious" Table2. That prediction is checkable and is the right kind of evidence to attach to a partial outcome.

## Recommendation for the thesis
Because this is the highest-information experiment for the qualitative comparison — the agent designed test infrastructure, generalized lessons across tasks, and built code that's API-driven rather than name-driven — it would be worth manually re-running just the last three tool calls to convert this from `partial` to either `success` or `failure`. The setup file at `/home/sing/demo/dynamic_pick_and_place.py` is the only prerequisite, and that's already in place.

## Notes for cross-referencing
- Generated controller: `../generated_scripts/02_dynamic_discovery_pick_place_controller.py`.
- Tool-call trace: `../orchestration_logs/02_dynamic_discovery_pick_place.jsonl`.
- Narrative transcript: `../orchestration_logs/02_dynamic_discovery_pick_place.md`.
