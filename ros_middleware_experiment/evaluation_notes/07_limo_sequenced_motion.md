# 07 — Sequenced motion: forward / backward / turn right — evaluation

| Field | Value |
| --- | --- |
| Task ID | `07_limo_sequenced_motion` |
| Outcome | **success** |
| Number of tool calls | **14** |
| Self-corrections | **1** |
| Failure mode (recovered) | **MCP client filesystem != Isaac host filesystem.** Agent first tried to write the controller to `/home/claude/demo/limo_drive.py` and reference it from Isaac Sim; the Isaac extension couldn't read that path. Recovered by running the controller logic inline via `isaac-sim:execute_script`. |
| Notable observations | See below |

## Verification of success
- All three motion phases ran to completion (forward 180 frames, backward 240, pivot-right 120).
- Final wheel rotation: ~0.277 rad on each wheel.
- Final joint velocities: ~−0.0002 rad/s (zero within noise).
- `get_isaac_logs` clean throughout the 9 s sequence.

## What was elegant
- **Correct wheel-sign convention from first principles.** The agent set FL+/FR−/RL+/RR− for forward and negated it for backward. That's the right sign pattern for a differential-drive base whose wheels face outward (the "outward" convention is the only thing the agent had to infer from the joint configuration in task 06).
- **Pivot-right via uniform-sign wheels** rather than via opposing-side wheels is a valid pattern on a 4-wheel skid-steer base like the LIMO, and it's the right choice given the velocity-drive mode (no body-twist conversion is needed; just set per-wheel velocities).
- **Decomposing the sequence into observable steps.** The agent ran each phase as a separate `execute_script` + `step_simulation` pair with a `get_joint_state` peek in between, rather than blasting the whole sequence in one call. This makes the trace much easier to evaluate after the fact (and made it easy to verify the stop settled).

## What was brittle
- **The filesystem boundary keeps biting.** Same MCP-vs-Isaac filesystem split that cost a self-correction in the static pick-and-place experiment (session 1) and in the warehouse-capture experiment (session 2). This is the third time in the experiment series; it's a memory-shape observation worth foregrounding in the thesis (see summary.md).
- The wheel speeds (4 rad/s for drive, 3 rad/s for pivot) are unjustified magic numbers — picked because they're "conservative". A more principled controller would compute them from a desired body-frame velocity and the robot's wheel radius / track width. The task didn't ask for that level of correctness, but it would be needed for any real navigation task.

## Notes for cross-referencing
- Transcript: `../orchestration_logs/07_limo_sequenced_motion.md`
- Tool-call trace: `../orchestration_logs/07_limo_sequenced_motion.jsonl`
- Reconstructed inline script: `../generated_scripts/07_limo_sequenced_motion_drive_sequence.py`
