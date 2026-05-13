# 05 — Warehouse env + camera + capture — transcript

> Source chat date: 2026-05-13. Continues from task 04. This is the longest task of the session and contains the only sustained failure mode.

## Verbatim prompt
> List available environments, choose a warehouse-like one, and load it.
> Create a camera and capture an image.

## Turn-by-turn summary

### T1 — list and choose
- Agent listed available environment assets; the warehouse-like options were `digital_twin_warehouse`, `simple_warehouse`, and `modular_warehouse_props`.
- Picked **`simple_warehouse`** ("full furnished warehouse — cleanest fit for 'warehouse-like' with robots inside").

### T2 — load env
- Loaded `simple_warehouse`. Robots from task 04 now sit inside the warehouse interior.

### T3 — new camera
- Existing `/World/WorkspaceCamera` was kept; the task explicitly asks for a *new* camera, so agent authored `/World/SceneCamera` positioned behind-and-above the Franka row (Frankas span x=0→4, Go1 at (1, 3)) with the look vector pointing down the row.

### T4 — first capture attempt
- `isaac-sim:capture_image(camera_prim_path=/World/SceneCamera)` → error: `'NoneType' has no __array_interface__`.
- Agent's diagnosis: the camera's render product hasn't been initialized; renderer needs a tick before it produces frames.

### T5 — recovery attempts (in order)

| # | Approach | Result |
|---|---|---|
| 1 | Check sim state, step a few physics frames, retry `capture_image` | Same error |
| 2 | `get_isaac_logs` to see what went wrong | No errors logged at all |
| 3 | `execute_script` to attach an RGB annotator to the render product manually, then retry `capture_image` | Annotator attached but shape is `(0,)` — no pixels yet |
| 4 | Attempt to save the frame to a path on *this* container (`/home/claude/...`) | Fails — Isaac runs on a different host; that filesystem isn't accessible. Same MCP/host filesystem split as the other session. |
| 5 | Save to Isaac's host instead, retry MCP `capture_image` | Same `NoneType` error |
| 6 | `step_async` + spin `app.update()` in the script | Doesn't complete — `step_async` can't finish while the script blocks the event loop |
| 7 | Retry `capture_image` on the original `/World/WorkspaceCamera` (clean, no annotator fiddling) | Same error — proves the issue is server-side, not caused by the agent's prior modifications |
| 8 | Play the simulation so the renderer ticks naturally, then capture | Still fails after 30 physics steps |

### T6 — self-correction: bypass `capture_image` entirely
Agent switched to the `isaacsim.sensors.camera.Camera` sensor API, which has its own image-grab pipeline. One-shot `execute_script` payload:
- Instantiates `Camera(prim_path=/World/SceneCamera, resolution=(1920, 1080))`.
- `cam.initialize()`.
- Pumps `omni.kit.app.next_update_async()` ~30 times to let the renderer settle.
- Reads `cam.get_rgba()`, slices off alpha, saves with PIL to `/tmp/scene_capture.png` on the Isaac host.

Result: **`(1080, 1920, 3)` of real pixel data saved**. The tool was broken; the underlying API works.

### T7 — getting the bytes back across the MCP boundary
Now needed to pull the PNG back to this container so the agent could verify the image. New struggle: the PNG was a few MB, too big to base64-stream through `execute_script` stdout in one call.

| # | Approach | Result |
|---|---|---|
| 1 | Stream base64 of full PNG back through stdout | Truncated — only got chunks `C000`–`C021`, would need many follow-up calls to reassemble |
| 2 | Have Isaac re-save at smaller resolution, re-encode | ~64 KB of base64 — still chunked across multiple lines |
| 3 | Decode the partial stream → only 3 KB out of 64 KB survived round-trip via stdout | Insufficient |
| 4 | Have Isaac re-encode as a small JPEG that fits in **one** base64 chunk | **Worked** — 16,652-char base64 string returned in a single stdout block |
| 5 | Decode locally, inspect | Real scene image: visible warehouse floor (concrete with seam lines, slightly visible Go1 robot at the right edge) |

### T7 diagnosis: framing
The first decoded image showed mostly **floor** — the camera was aimed too low. A horizontal seam through the middle was a residual artifact from re-initializing the Camera at a new resolution mid-session before the renderer had fully settled.

### T8 — reposition and re-capture
Agent re-aimed `/World/SceneCamera`:
- Robot span: Frankas at x=0..4, y=0; Go1 at (1, 3). Center of action ≈ (2, 1, 0).
- New camera target: ~5 m back along −Y, ~2 m up, looking at (2, 1, 0).
- Used a single-shot script that initializes the Camera at the final resolution from the start and gives the renderer enough updates to settle before reading (no mid-flight resolution change).

The chat narrative I'm working from ends at this re-capture step. The bundle therefore documents Task 05 as **partial**: an image was captured (the cube-on-the-floor framing wasn't the intended shot, but the pipeline was proven), the camera was repositioned, but final visual confirmation of the *retake* with the new framing isn't in the captured chat.

## Final state at end of captured chat
| Element | Status |
| --- | --- |
| `simple_warehouse` environment | loaded |
| `/World/SceneCamera` | authored, repositioned to view the robots |
| First captured frame | `/tmp/scene_capture.png` on Isaac host (1920×1080), framing too low |
| Recapture | initiated, final frame not confirmed in transcript |
| `capture_image` MCP tool | **broken on this server** — confirmed not agent-caused; documented for the thesis |
