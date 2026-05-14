# 07 — Sequenced motion: forward / backward / turn right — transcript

> Source chat date: 2026-05-13. Continues from task 06.

## Verbatim prompt
> Make the robot move forward for 3 seconds, then move backward for 4 seconds and then finally turn right for 2 seconds

## Turn-by-turn summary

### T1 — modelling the problem
- Agent recognizes the LIMO as a differential-drive base from the task-06 joint data (4 revolute wheels, velocity-drive mode). Decides to issue wheel-velocity commands directly rather than a body-twist.
- Agent checks simulation state with `isaac-sim:get_simulation_state` — paused.

### T2 — first attempt: write a script file
- Agent tries to write the controller to a file under `/home/claude/demo/...` and reference it from Isaac Sim.
- **Failure:** the Isaac Sim extension can't reach `/home/claude/`. Same MCP/host filesystem split observed in the other experiments (sessions 1 and 2).

### Self-correction #1 — inline payload via execute_script
- Agent pivots to executing the controller logic directly via `isaac-sim:execute_script` rather than writing a file. The same drive sequence runs inline. (The script logic is preserved in `../generated_scripts/07_limo_sequenced_motion_drive_sequence.py`.)

### T3 — drive sequence
The sequence runs in three named phases plus a final stop:
- `forward` for 3 s (180 physics frames at 60 Hz) — wheels: FL+, FR−, RL+, RR−.
- `backward` for 4 s (240 frames) — negate the forward pattern.
- `pivot_right` for 2 s (120 frames) — all four wheels in the same sign so the body rotates in place to the right.
- `stop` — all zeros, brief settle window.

Between phases the agent calls `isaac-sim:step_simulation` to advance the simulator and observe progress, and uses `isaac-sim:get_joint_state` to confirm the motion is happening.

### T4 — verification
After the full 9 s sequence:
- All wheels report ~0.277 rad of accumulated rotation (consistent with the asymmetric forward/backward/pivot durations).
- All joint velocities are ~−0.0002 rad/s — essentially zero, confirming the stop command settled.
- No physics errors in `isaac-sim:get_isaac_logs`.

### Summary table emitted to the user
| Phase | Duration | Wheel command | Frames |
|---|---|---|---|
| **Forward** | 3 s | FL+, FR−, RL+, RR− | 180 |
| **Backward** | 4 s | FL−, FR+, RL−, RR+ | 240 |
| **Turn right** | 2 s | all wheels + (pivot) | 120 |
| **Stop** | — | all zeros | — |

## Final state
| Field | Value |
| --- | --- |
| Total wheel rotation | ~0.277 rad each |
| Final joint velocities | ~−0.0002 rad/s (essentially zero) |
| Physics errors | none |
| Self-corrections | 1 (filesystem boundary → inline `execute_script`) |
