# ROS middleware experiment — summary (tasks 06–08)

Source: a single chat session on 2026-05-13 against the LIMO robot in the `limo_example.usd` scene. The Isaac Sim ROS 2 bridge is active throughout; the experiment exercises the same simulator the earlier sessions used, but the focus is on the middleware boundary (joint topics → wheel commands → ROS 2 topics → odometry).

## Aggregate table

| Task ID | Outcome | Tool calls | Self-corrections | Primary failure mode (if any) | Headline observation |
| --- | --- | ---: | ---: | --- | --- |
| `06_connect_limo_show_topics` | success | 5 | 0 | None | Unprompted, correct identification of stiffness=0+damping=1e6 as velocity-drive mode, with a forward-reference to the `/cmd_vel` interface that becomes task 08's central artifact. |
| `07_limo_sequenced_motion` | success | 14 | 1 | MCP/host filesystem split (3rd recurrence in the experiment series). | Differential-drive interpreted correctly from joint configuration. 9-second sequence ran cleanly, wheels settled to zero velocity. |
| `08_limo_ros2_topics_roundtrip` | partial | 3 executed (+3 not-run) | 1 | "ROS MCP" tool surface unavailable; agent fell back to `rclpy` directly. | Classification by ROS message type (not topic name) and LiDAR sector computation from `angle_min` + `angle_increment` are both portable, correct abstractions. |

**Totals:** 22 executed tool calls, 2 self-corrections, 2 successes, 1 partial.

## Cross-task themes

**The MCP/host filesystem split is the most recurrent friction in this entire experiment series.** It has now bitten the agent in:
1. Session 1 task 01 — initial controller written under `/home/claude/demo/`; had to be base64-transferred to `/home/sing/demo/`.
2. Session 2 task 05 — tried to save captured PNG to client-side path; same fix needed.
3. Session 3 task 07 — first attempted to save the drive sequence to a `/home/claude/...` path before pivoting to inline `execute_script`.

That's three independent recurrences across three sessions of the same agent on the same MCP server. The lesson is not retained as background knowledge between or within sessions; it only manifests in code that already contains the workaround. **Recommendation:** the MCP server description for `execute_script` and `create_file` should include a one-sentence note about the host/client boundary. This is the highest-ROI documentation change.

**Graceful tool-surface fallback is a real, transferable agent capability.** Two tasks in this series asked for something that wasn't available (a working `capture_image` in session 2; a "ROS MCP" tool surface in this session). In both cases the agent identified a lower-level alternative that exposed the same underlying capability — `Camera` sensor API in session 2, `rclpy` inside `execute_script` here — and made forward progress. This is one of the strongest qualitative signals in the bundle.

**Velocity-drive vs. position-drive matters more than the task list suggests.** Both session 2 (Go1 with zeroed drives → will collapse) and this session (LIMO with stiffness=0, damping=1e6 → wheel-velocity-driven only) hinge on correctly reading the joint drive configuration. The agent surfaced both correctly without being asked. A naive controller that issued position targets to either robot would have failed silently. This is the kind of robot-config literacy a middleware-focused thesis should highlight.

## Middleware-specific findings

**ROS 2 bridge round-trip works through `rclpy` in `execute_script`.** The Isaac Sim ROS 2 bridge publishes/subscribes on the same DDS bus as any external ROS node, and `rclpy` calls from inside `execute_script` participate in that bus. This is the cleanest interface between an LLM agent and a running ROS 2 graph available on this MCP server, given that no ROS-MCP-specific tool surface is connected.

**The right level of abstraction for topic classification is the message type.** `geometry_msgs/msg/Twist` is the same across renames of `/cmd_vel`, `/limo/cmd_vel`, `/robot0/cmd_vel`, etc. Classification by name string is brittle; classification by type is robust. The agent did this correctly in task 08 without being told to.

**LaserScan geometry is publisher-dependent.** Different publishers use different angle conventions (CW vs CCW, start at forward vs +90°, full 360° vs limited FOV). The agent correctly reconstructed the front sector from each message's own `angle_min` + `angle_increment` rather than assuming a fixed index range. This is a small piece of robustness that has outsized value across scene-to-scene reuse.

## Suggested next experiments

1. **Complete task 08.** The cleanest extension of this bundle. Re-run the last three steps (publish forward Twist, stop, sample odom delta) in one `execute_script` call and report the displacement. This is a partial → hard-outcome conversion at minimal cost.
2. **Cross-session lesson persistence test.** Re-run task 07 in a fresh session with a system-prompt hint about the MCP/host filesystem boundary. Measure whether the self-correction count drops to zero or whether procedural lessons need to be in the prompt and not just the chat history to actually persist.
3. **Tool-surface fallback benchmark.** Construct a small benchmark of "X tool requested, X not available, lower-level Y works" pairs. The two existing examples (`capture_image` → `Camera` API; `ros-mcp` → `rclpy`) suggest this is a coherent capability worth measuring formally.
4. **Drive-config diagnostic as a first-class tool.** A `diagnose_robot_drives(prim_path)` MCP tool that returns "velocity-driven (OK)", "position-driven (OK)", or "drives appear zeroed — robot will collapse on play" would have removed two unprompted-warning paragraphs across this experiment series. Worth proposing upstream.
