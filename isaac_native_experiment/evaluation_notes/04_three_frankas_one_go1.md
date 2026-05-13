# 04 — Three Frankas + one Go1 — evaluation

| Field | Value |
| --- | --- |
| Task ID | `04_three_frankas_one_go1` |
| Outcome | **success** |
| Number of tool calls | **5** |
| Self-corrections | **0** |
| Failure modes encountered | None |
| Notable observations | See below |

## Verification of success
- Four robots at requested positions, correct DOF counts (FR3: 9, Go1: 12).
- All five tool calls succeeded on first try.

## What was elegant
- **The agent surfaced two diagnostics the user did not ask for, both of which would have caused confusion later if left silent:**
  1. **"franka" → FR3, not Panda.** The `franka` key in `create_robot` resolves to the Franka FR3 in Isaac 5.1, so the joint names are `fr3_joint1..7` (not `panda_joint1..7`). This is the exact ambiguity that caused the RMPflow preset bug in session 1 of this experiment. Calling it out at robot-creation time would have saved the session-1 self-correction entirely.
  2. **Go1 drives are zeroed.** Every Go1 joint reports `stiffness=damping=0`. The Frankas show the same warning on `fr3_finger_joint2`, but on the FR3 that's the *mimic* finger (benign); on the Go1 it's all 12 joints and the robot will collapse the moment physics starts. The agent gave concrete numbers (~50/5 for hips/thighs, ~30/3 for calves) as a starting point. This is the kind of unsolicited "this will surprise you in 30 seconds" warning that distinguishes useful agentic behaviour from naively-correct behaviour.
- The agent also flagged that `/World/WorkspaceCamera` from task 03 will now miss most of the new scene, and offered to reposition it. It did *not* reposition without asking, which is the right call — that was beyond the prompt.

## What was brittle
- None — the task is mechanical, but the proactive warnings hide an underlying brittleness in the MCP `create_robot` tool: it returns the warnings but **does nothing to fix them**, even when the fix is the obvious next step (set sensible default drives for the Go1). If the user had pressed play without reading the warnings, the experiment would have failed silently.

## Notes for cross-referencing
- Transcript: `../orchestration_logs/04_three_frankas_one_go1.md`
- Tool-call trace: `../orchestration_logs/04_three_frankas_one_go1.jsonl`
- No generated scripts (all direct MCP tool calls)
