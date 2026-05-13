# Isaac Sim native experiment — summary (tasks 03–05)

Source: a single chat session on 2026-05-13 covering three sequential tasks against a fresh stage. Tasks 03 → 04 → 05 build on each other (each task inherits the prior stage).

## Aggregate table

| Task ID | Outcome | Tool calls | Self-corrections | Primary failure mode (if any) | Headline observation |
| --- | --- | ---: | ---: | --- | --- |
| `03_connection_lights_camera` | success | 6 | 0 | None | Did not naively treat `prim_count: 14` as "scene populated" — verified that all 14 prims were Kit defaults before deciding to create a physics scene. |
| `04_three_frankas_one_go1` | success | 5 | 0 | None | Two unprompted diagnostics: "franka" resolves to FR3 (not Panda), and Go1's 12 joints have zeroed drives — will collapse on play unless tuned. Concrete remediation values offered. |
| `05_warehouse_camera_capture` | partial | 23 | 4 | **MCP `capture_image` tool returns None from its render-product annotator on this server.** Bug confirmed not agent-caused (reproduced on a clean camera with no prior modifications). | After 8 distinct recovery attempts, agent bypassed the broken tool by using `isaacsim.sensors.camera.Camera` directly and captured a real 1920×1080 frame. Final reframed capture was initiated but not confirmed in the captured chat. |

**Totals:** 34 tool calls, 4 self-corrections, 2 clean successes, 1 partial.

## Cross-task themes

**Proactive diagnostics beat reactive ones.** Task 04 surfaces both the FR3-vs-Panda model ambiguity *and* the Go1 drive issue **at robot-creation time, before any motion is attempted**. The first one is exactly the bug that cost session 1 a self-correction (wrong RMPflow preset). The second one is a silent failure mode that produces no error at all — the Go1 just falls over on play. The thesis comparison should weight tasks like this favourably: zero-error runs that ship with usable warnings are higher-information than zero-error runs that ship with nothing.

**Tool bugs are recoverable when the agent knows the API beneath.** The `capture_image` failure in task 05 is the most severe environment-side issue in the session. The agent solved it not by trying twenty variants of the broken call but by dropping one layer down to the actual sensor API. This pattern — "the wrapper is broken, the wrapped thing isn't" — generalizes; the thesis can use it as a benchmark for *failure-mode literacy*.

**Procedural knowledge doesn't auto-persist across tasks within a session.** Session 1 of this experiment taught the agent the MCP-vs-Isaac filesystem split. In task 05, recovery attempt #4 ran straight into the same trap (`/home/claude/...` not visible to Isaac). The fix is the same; the lesson hadn't been internalized. A useful protocol-level finding: lessons learned via self-correction within an agent's run **need to be written into the controller code or back into the system prompt** to be reliable; they don't accumulate as background knowledge.

## Failure-mode catalogue (across both sessions of this experiment)

| Class | Examples | Recovery cost |
| --- | --- | --- |
| **LLM-side reasoning errors** | Wrong RMPflow preset (`"Franka"` for FR3) | 1 probe, ~2 calls |
| **MCP/Isaac filesystem split** | Writing controller to `/home/claude/...` instead of `/home/sing/...`; trying to save captured PNG to client-side path | Recurring — once per session |
| **MCP tool semantics ≠ underlying state** | `edit_action_graph` setting transient OmniGraph attrs flushed on `timeline.stop()`; `capture_image` annotator returns None | 4–8 calls per incident |
| **USD ↔ PhysX desync** | USD `translateOp` reset doesn't teleport PhysX rigid bodies | 3 calls per incident |
| **Event-loop / async confusion** | `step_async` from inside a blocking script doesn't complete | 1 call to diagnose, 1 to switch approach |
| **MCP transport limits** | Large PNG over base64-stdout truncates | 3-4 calls to find a smaller format |

The pattern is consistent with session 1's headline: **the integration semantics cost dwarfs the LLM-reasoning cost**. In 34 tool calls across this session, exactly zero were lost to model misunderstandings; all four self-corrections were environment-shape issues.

## Suggested next experiments

1. **Repro `capture_image` bug in isolation.** A minimal script that authors a camera, calls `capture_image`, and dumps the annotator state. File upstream. The thesis chapter benefits from a tight reproduction in addition to the agent's 8-attempt diagnostic trail.
2. **Cross-task lesson persistence.** Re-run task 05 in a fresh session, but seed the system prompt with the session-1 lesson about filesystem boundaries. Measure whether self-correction count drops to zero or whether the lesson needs to be encoded as code/tooling to actually stick.
3. **Go1 drive defaults.** Either the MCP `create_robot` tool or a follow-up `tune_drives` tool should ship sensible defaults for known robots. This is the most actionable upstream improvement surfaced across both sessions.
