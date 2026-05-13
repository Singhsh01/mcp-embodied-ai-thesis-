# 01 — Static FR3 pick-and-place — evaluation

| Field | Value |
| --- | --- |
| Task ID | `01_static_pick_place` |
| Outcome | **success** |
| Number of tool calls | **54** (counted from `01_static_pick_place.jsonl`) |
| Self-corrections | **4** (host-filesystem fix, FR3 preset fix, timeline.stop reset, direct USD attribute authoring) |
| Failure modes encountered (all recovered) | (a) scene-state mismatch — agent wrote the controller to its *own* `/home/claude/demo/` instead of the Isaac host's filesystem; (b) wrong API argument — loaded the `"Franka"` RMPflow preset whose joint names (`panda_joint*`) don't match the FR3's (`fr3_joint*`); (c) USD-vs-PhysX state desync — pose reset via `translateOp` mid-simulation ejected the rigid body on resume; (d) transient OmniGraph attribute storage — `edit_action_graph` set ScriptNode inputs that did not survive `timeline.stop()`. |
| Notable observations | See below. |

## Verification of success
- Cube start: (0.500, **−0.350**, 0.425) on Table 1.
- Cube end: (0.500, **+0.337**, 0.425) on Table 2, linear+angular velocity zero, settled after 60-frame settle window.
- TCP ended at (0.50, +0.35, 0.56) — the post-place retreat waypoint 15 cm above Table 2.
- 0 errors in `get_isaac_logs` during the successful run (only pre-init FR3 inertia-tensor warnings).
- The success criterion *"no hardcoded coordinates"* is satisfied: every constant in the controller's `--- Queried scene constants ---` block is traceable to a specific `get_prim_info` call documented in the transcript.

## What was elegant
- The 8-phase state-machine pattern (approach → descend → grasp → lift → approach → descend → release → retreat) with per-phase minimum dwell frames and a 2-cm Cartesian convergence tolerance is a small amount of code that handles a non-trivial motion robustly. The same pattern transferred cleanly into task 02.
- Once the agent realized the host filesystem mismatch, the base64-over-`execute_script` file transfer worked on the first attempt and was reused without ceremony in task 02.
- The auto-reset of `state:omni_initialized` on `edit_action_graph` is a nice MCP affordance that the agent exploited correctly to force re-imports.

## What was brittle
- **`create_action_graph(script_file=...)` is not actually persistent.** The MCP tool reports the attributes as set, but they only live in the OmniGraph Controller's transient layer. Any timeline stop/restart drops them silently. The agent had to learn the hard way that the durable path is direct `Usd.Attribute.Set()`. This is a sharp edge worth flagging in the thesis: MCP-tool semantics can diverge from what the underlying engine treats as authoritative state.
- Three of the four self-corrections come from **layering issues** (MCP ↔ Kit ↔ USD ↔ PhysX): file paths cross a process boundary, USD authoring doesn't reach PhysX without a stop, OmniGraph attributes route through a non-USD store. Each layer is individually documented, but the *interactions* aren't, and that is exactly where the agent stumbled.
- The `"Franka"` preset bug is the only properly LLM-side mistake — the rest are environment quirks. Even this one was caught and fixed from the log entry alone, in one tool-call probe (`get_supported_robot_policy_pairs()`).

## What surprised me
- The agent never tried to look at the URDF or robot description to decide between presets; it inferred the fix straight from the runtime exception `'panda_joint1'`. That's the right inference for the wrong reason in some scenes, but here it converged correctly.
- The agent voluntarily added the FR3-specific check `joint_prefix = robot.dof_names[0].split("_")[0]` into the task-02 controller, generalizing the lesson without being asked to. That is exactly the kind of carry-over the thesis qualitative evaluation should reward.

## Notes for cross-referencing
- Final controller: `../generated_scripts/01_static_pick_place_controller_fixed.py`.
- Original controller with bug retained: `../generated_scripts/01_static_pick_place_controller.py`.
- Tool-call trace: `../orchestration_logs/01_static_pick_place.jsonl`.
- Narrative transcript: `../orchestration_logs/01_static_pick_place.md`.
