# Isaac Sim native experiment — summary (tasks 01–05)

Source: two chat sessions on 2026-05-13 using the `isaac-sim` MCP tool surface plus Claude's local file/bash tools. Tasks 01–02 form one session; tasks 03–05 form a second session against a fresh stage. Within each session, later tasks inherit the prior task's stage state.

## Aggregate table

| Task ID | Outcome | Tool calls | Self-corrections | Primary failure mode (if any) | Headline observation |
| --- | --- | ---: | ---: | --- | --- |
| `01_static_pick_place` | success | 54 | 4 | All four self-corrections were layering issues (MCP/Kit/USD/PhysX), not LLM reasoning errors. Only the wrong RMPflow preset (`"Franka"` vs `"FR3"`) was a model-side mistake; it was caught from the runtime log and fixed in one probe. | Once the agent learned the durable-state route (direct `Usd.Attribute.Set` instead of `edit_action_graph`), behaviour became deterministic. |
| `02_dynamic_discovery_pick_place` | partial | 12 executed (+3 not-run) | 0 | None observed. Chat ended after the controller was written and transferred to the Isaac host but before the action graph was rebuilt and stepped. | Agent applied all of task-01's lessons preemptively: detected RMPflow preset by joint-name prefix, used USD/UsdPhysics API queries instead of name matching, and proactively augmented the scene so the discovery test wouldn't be degenerate. |
| `03_connection_lights_camera` | success | 6 | 0 | None | Did not naively treat `prim_count: 14` as "scene populated" — verified that all 14 prims were Kit defaults before deciding to create a physics scene. |
| `04_three_frankas_one_go1` | success | 5 | 0 | None | Two unprompted diagnostics: "franka" resolves to FR3 (not Panda), and Go1's 12 joints have zeroed drives — will collapse on play unless tuned. Concrete remediation values offered. |
| `05_warehouse_camera_capture` | partial | 23 | 4 | **MCP `capture_image` tool returns None from its render-product annotator on this server.** Bug confirmed not agent-caused (reproduced on a clean camera with no prior modifications). | After 8 distinct recovery attempts, agent bypassed the broken tool by using `isaacsim.sensors.camera.Camera` directly and captured a real 1920×1080 frame. Final reframed capture was initiated but not confirmed in the captured chat. |

**Totals:** 100 executed tool calls, 8 self-corrections, 3 clean successes, 2 partials.

## Cross-task themes

**LLM-side errors are rare; environment-layer errors dominate.** Across all five tasks, exactly one mistake was a genuine LLM reasoning error (the `"Franka"` RMPflow preset). The other seven self-corrections were about boundaries between systems: MCP client vs. Isaac host filesystems, USD authoring vs. PhysX state, OmniGraph attribute storage vs. USD attribute storage, broken wrapper tools, async confusion, and MCP-transport size limits. For a thesis comparing MCP-mediated agentic control to other paradigms, this is the headline finding: **the cost is not in the model, it's in the integration semantics**.

**Proactive diagnostics beat reactive ones.** Tasks 04 and 06 (see the ROS middleware bundle) both produced zero-error runs that *also* shipped two unprompted warnings each — the FR3-vs-Panda model ambiguity, the Go1's zeroed drives, the LIMO's velocity-drive mode. The FR3-vs-Panda warning is the exact ambiguity that cost a self-correction in task 01; if it had been delivered there, task 01 would have run in roughly two-thirds the tool calls. The thesis comparison should weight tasks like this favourably: zero-error runs that ship with usable warnings are higher-information than zero-error runs that ship with nothing.

**Code generalizes faster than the agent can be asked to generalize.** The task-02 controller is genuinely API-driven (CollisionAPI / RigidBodyAPI / ArticulationRootAPI) and includes generalizations the prompt did not ask for (reach-radius guard, joint-prefix→preset mapping). The agent moved up the abstraction ladder once given a second similar problem, without prompting.

**Tool bugs are recoverable when the agent knows the API beneath.** The `capture_image` failure in task 05 is the most severe environment-side issue in the experiment. The agent solved it not by trying twenty variants of the broken call but by dropping one layer down to the actual sensor API (`isaacsim.sensors.camera.Camera`). This pattern — "the wrapper is broken, the wrapped thing isn't" — generalizes; it shows up again in the ROS middleware experiment when a missing "ROS MCP" tool surface is replaced by direct `rclpy` calls inside `execute_script`. The thesis can use this as a benchmark for *failure-mode literacy*.

**Tooling encourages the right discipline by accident.** The MCP affordance that `edit_action_graph` auto-resets `state:omni_initialized` is small but well-shaped: it nudges the agent toward "re-author the script path → ScriptNode re-imports", which is precisely the right control-flow. Where the tooling failed (transient OmniGraph storage), the agent had to invent the workaround from logs.

**Procedural knowledge doesn't auto-persist across tasks within a session.** Task 01 taught the agent the MCP-vs-Isaac filesystem split. In task 05, recovery attempt #4 ran straight into the same trap (`/home/claude/...` not visible to Isaac). The fix is the same; the lesson hadn't been internalized. A useful protocol-level finding: lessons learned via self-correction within an agent's run **need to be written into the controller code or back into the system prompt** to be reliable; they don't accumulate as background knowledge.

## Failure-mode catalogue (across all five tasks)

| Class | Examples | Recovery cost |
| --- | --- | --- |
| **LLM-side reasoning errors** | Wrong RMPflow preset (`"Franka"` for FR3) in task 01 | 1 probe, ~2 calls |
| **MCP/Isaac filesystem split** | Task 01: writing controller to `/home/claude/...` instead of `/home/sing/...`. Task 05: trying to save captured PNG to client-side path. | Recurring — once per session |
| **MCP tool semantics ≠ underlying state** | Task 01: `edit_action_graph` setting transient OmniGraph attrs flushed on `timeline.stop()`. Task 05: `capture_image` annotator returns None. | 4–8 calls per incident |
| **USD ↔ PhysX desync** | Task 01: USD `translateOp` reset doesn't teleport PhysX rigid bodies | 3 calls per incident |
| **Event-loop / async confusion** | Task 05: `step_async` from inside a blocking script doesn't complete | 1 call to diagnose, 1 to switch approach |
| **MCP transport limits** | Task 05: large PNG over base64-stdout truncates | 3–4 calls to find a smaller format |

The pattern is consistent across all five tasks: in 100 executed tool calls, exactly one was lost to model misunderstanding; seven of eight self-corrections were environment-shape issues.

## Coverage and gaps

- **What we have hard evidence for:** that a Claude-class LLM can drive Isaac Sim through MCP to (a) author and run a multi-phase RMPflow pick-and-place from scratch with no hardcoded coordinates, (b) recover cleanly from a wrong RMPflow preset, (c) convert a hardcoded controller into an API-driven dynamic-discovery one, (d) build a workspace scene with physics, lights, and a camera, (e) instantiate heterogeneous robots while proactively flagging silent failure modes, and (f) work around a broken capture pipeline by dropping to the underlying sensor API — across roughly 100 tool calls and 8 self-corrections.
- **What we don't yet have:** end-to-end execution evidence for task 02 (the dynamic-discovery script exists and is on the Isaac host; only the three closing tool calls were not made) and for task 05's reframed capture (initiated but not confirmed in the captured chat). Re-running those small follow-ups would convert both partial results.

## Suggested next experiments (for the thesis)

1. **Failure injection.** Re-run task 01 with the `"Franka"` preset on purpose, give the agent the failing log, and time how long the recovery takes from a cold conversation. Compare against a non-MCP baseline that has to read the error from a terminal.
2. **Tool-surface stress test.** Repeat task 02 with the third table positioned just *outside* the reach radius and verify the controller picks the only reachable destination — i.e. that the reach-radius guard is doing useful work rather than coincidentally matching the scene.
3. **Filesystem-boundary documentation.** The single most impactful artifact the thesis could ship is a one-page table mapping MCP tool ↔ where state actually lives (USD layer, OmniGraph store, PhysX state, host filesystem). Every self-correction in this experiment series reduced to a row missing from that table.
4. **Repro `capture_image` bug in isolation.** A minimal script that authors a camera, calls `capture_image`, and dumps the annotator state. File upstream. The thesis chapter benefits from a tight reproduction in addition to the agent's 8-attempt diagnostic trail.
5. **Cross-task lesson persistence.** Re-run task 05 in a fresh session, but seed the system prompt with the task-01 lesson about filesystem boundaries. Measure whether self-correction count drops to zero or whether the lesson needs to be encoded as code/tooling to actually stick.
6. **Go1 drive defaults.** Either the MCP `create_robot` tool or a follow-up `tune_drives` tool should ship sensible defaults for known robots. This is the most actionable upstream improvement surfaced across the experiment series.
