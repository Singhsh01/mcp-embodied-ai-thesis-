# 08 — LIMO ROS 2 round-trip — evaluation

| Field | Value |
| --- | --- |
| Task ID | `08_limo_ros2_topics_roundtrip` |
| Outcome | **partial** |
| Number of tool calls | **3 executed** (+ 3 documented as not-executed before the chat ended) |
| Self-corrections | **1** (pivoted from "ROS MCP" to `rclpy` inside Isaac Sim's Python when the requested tool surface wasn't connected) |
| Failure mode (recovered) | **Requested tool surface unavailable.** The prompt explicitly asked for "ROS MCP", but no ROS-specific MCP server was connected on this session. Agent didn't ask or fail — went straight to `rclpy` inside `execute_script`, riding the Isaac Sim ROS 2 bridge that was already publishing on DDS. |
| Notable observations | See below |

## Why "partial" and not "success"
- **Topic enumeration + classification**: complete.
- **LiDAR subscription + front-clearance check**: complete; front was reported clear.
- **`/cmd_vel` publish + zero-Twist stop + odometry-delta verification**: the agent declared the plan but the captured chat ends *immediately before* these steps were executed. The script in `../generated_scripts/08_limo_ros2_topics_roundtrip_rclpy_session.py` contains the publish + odom-sampling logic the agent had planned to run; a future evaluator can re-run that script in one `execute_script` call to convert this to a hard success or failure.

## What was elegant
- **The right pivot.** "ROS MCP" was the requested tool; `rclpy` is the actual underlying capability. Once the agent realized there was no ROS-MCP server, it didn't get stuck asking — it used the lower-level interface that the simulator already exposes. This is the same pattern as session 2's task 05, where the broken `capture_image` tool was bypassed via the `Camera` sensor API directly. **Wrapper missing/broken → wrapped thing works.**
- **Classification by message type, not topic name string.** `node.get_topic_names_and_types()` returns the DDS type for each topic; matching on `geometry_msgs/msg/Twist` (etc.) keeps the controller portable across scenes where the publisher chose `/limo/cmd_vel` instead of `/cmd_vel`. This is the right level of abstraction for "find the topic that does X".
- **LiDAR front-window computation is publisher-agnostic.** The script reconstructs the front sector from the `LaserScan` message's own `angle_min` + `angle_increment` rather than assuming the array indexing convention. This survives publishers that scan clockwise vs counter-clockwise, that start at forward vs at +90°, that publish 360° vs limited FOV, etc.

## What was brittle
- **Cross-task lessons still don't persist.** The agent didn't even *try* writing the rclpy code to `/home/claude/...` and importing it — it went straight to inline `execute_script`. But that's not a learned lesson, that's a coincidence: the requested behaviour (a long-running ROS session with subscriptions and publishers) is the kind of thing you'd run inline anyway. The lesson about filesystem boundaries from sessions 1, 2, and task 07 of this very session hasn't really been internalized — it just doesn't apply here.
- **The cut-off.** Three of the most important tool calls (publish, stop, odom-compare) were not made. A one-line "let's run it" prompt-continuation would have completed the task.

## What surprised me
- The agent committed to a concrete sector size (±15°) and clearance threshold (0.5 m) without asking the user. Those are unsolicited defaults but defensible ones for a small mobile robot — a more cautious agent might have asked, which would have cost a turn for very little information gain.

## Recommendation for the thesis
- This task is the cleanest example in the experiment series of **graceful tool-surface fallback**: the literal prompt asked for a capability that didn't exist, the agent identified an alternate path through the same physical interface, and made forward progress. Worth quoting verbatim in the chapter as a contrast with the brittle-recovery pattern in session 2's `capture_image` saga.
- Re-running the last three steps (3 tool calls, no new code needed) would convert this from partial to a hard outcome.

## Notes for cross-referencing
- Transcript: `../orchestration_logs/08_limo_ros2_topics_roundtrip.md`
- Tool-call trace: `../orchestration_logs/08_limo_ros2_topics_roundtrip.jsonl`
- Reconstructed rclpy session: `../generated_scripts/08_limo_ros2_topics_roundtrip_rclpy_session.py`
