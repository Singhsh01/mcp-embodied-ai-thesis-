# 05 — Warehouse env + camera + capture — evaluation

| Field | Value |
| --- | --- |
| Task ID | `05_warehouse_camera_capture` |
| Outcome | **partial** |
| Number of tool calls | **23** |
| Self-corrections | **4** (host-filesystem split rediscovered, abandoned `step_async`, bypassed broken `capture_image` tool, JPEG-instead-of-PNG to fit stdout) |
| Primary failure mode | **MCP `capture_image` tool is broken on this server** — its render-product RGB annotator returns `None`, surfacing as `'NoneType' has no __array_interface__`. Verified across multiple cameras (`/World/SceneCamera`, `/World/WorkspaceCamera`), with and without manual annotator attachment, with and without timeline playing, with and without prior physics stepping. Not caused by the agent's prior modifications. |
| Notable observations | See below |

## Why "partial" and not "success"
The environment was loaded, the camera was authored, and **a real 1920×1080 frame was successfully captured** (saved to `/tmp/scene_capture.png` on the Isaac host, decoded back in this container, verified to contain actual scene pixels). The first decoded frame showed the warehouse floor with the Go1 visible at the right edge, confirming the rendering pipeline works end-to-end.

The reason this is *partial* and not *success*: the first capture's framing was wrong (camera aimed too low), the agent identified the problem and initiated a reposition + recapture, but the captured chat narrative ends before the reframed shot is confirmed. The retake is a one-call follow-up.

## What was elegant
- **Persistence with diagnosis at every step.** The agent tried 8 distinct recovery paths for `capture_image` before abandoning the tool, and each one tested a *different* hypothesis (render product not initialized → step physics; annotator not attached → attach manually; renderer needs ticks → run `step_async`; possible prior modifications interfering → retry on a clean camera; timeline not running → play first). The bug was real and the diagnosis chain was correct even though no single attempt fixed it.
- **The eventual workaround (`isaacsim.sensors.camera.Camera` directly) is the right abstraction.** The MCP `capture_image` tool wraps a render-product annotator; the `Camera` sensor class has its own pipeline. When wrapper tools break, dropping to the underlying API is the textbook fix.
- **Recognition of secondary issues without ego.** When the second capture worked but produced a low-framed shot with a horizontal seam, the agent correctly attributed the seam to mid-flight resolution change (renderer hadn't settled) and the framing to its own camera pose, not to a continuation of the prior bug. Two separate problems, correctly factored.

## What was brittle
- The MCP `capture_image` tool itself. The thesis should call this out as a concrete reproducible bug: every camera, every state, same error. The agent's verification on `/World/WorkspaceCamera` (which had no agent-side modifications) is the key piece of evidence.
- The **MCP stdout boundary**. PNGs of even modest size don't survive base64-over-stdout in one tool call. The agent eventually solved this by switching to a single-chunk JPEG, but the friction is real — it cost roughly 4 tool calls of fumbling.
- **`step_async` from a blocking script doesn't complete.** Worth documenting: inside an `execute_script` payload, you cannot await an async Kit operation while spinning `app.update()`; the event loop is already yours. The fix is to schedule via `asyncio.ensure_future(...)` and let Kit's existing loop drive it.

## What surprised me
- The agent did *not* try `reset_simulation` or stage-reload as a "have you tried turning it off and on again" attempt before bypassing the tool. That's actually the right call — restarting state without root-cause diagnosis is anti-evidence — but it's also unusual restraint for an agent in a stuck loop.
- The session-1 lesson about **MCP client vs. Isaac host filesystems** had to be rediscovered here (recovery attempt #4: tried to save to `/home/claude/...`). The agent didn't carry that lesson across tasks within the same conversation. This is a memory-shape observation worth flagging in the thesis: lessons learned through self-correction don't persist as "I know this now" — they persist only as code that already contains the workaround. Pure procedural knowledge ("write to /home/sing/..., not /home/claude/...") gets re-learned each time.

## Recommendation for the thesis
- Document `capture_image` as a known-broken tool on this MCP server (file an issue upstream if applicable; the workaround in `../generated_scripts/05_warehouse_camera_capture_capture_helper.py` is a drop-in replacement).
- The 8-attempts-to-diagnose recovery chain is the **strongest qualitative evidence in this session** that the agent's failure-handling is real, not theatrical. Worth quoting individual recovery attempts in the chapter.
- A meta-experiment: re-run task 05 with a one-line preamble that includes the session-1 lesson ("the Isaac process can't see `/home/claude/...`; save files to `/home/sing/...`"). Measure whether the cross-task transfer of procedural knowledge survives prompt-level prompting.

## Notes for cross-referencing
- Transcript: `../orchestration_logs/05_warehouse_camera_capture.md`
- Tool-call trace: `../orchestration_logs/05_warehouse_camera_capture.jsonl`
- Capture helper that bypassed the broken tool: `../generated_scripts/05_warehouse_camera_capture_capture_helper.py`
