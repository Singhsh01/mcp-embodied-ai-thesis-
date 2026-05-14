# 06 — Connect + show current robot topics

## Task ID & goal
**Task ID:** `06_connect_limo_show_topics`
**One-line goal:** Connect to the running Isaac Sim instance and surface the joint state and drive configuration of the LIMO robot.

## Verbatim prompts sent to Claude
> Connect to robot (limo).

Then, on the next turn:

> show me current robot topics

## Initial scene state
- **USD file:** `limo_example.usd` (pre-loaded by the user).
- **Objects present:** 243 prims, including a LIMO ROS robot at `/Root/limo_ROS`.
- **Simulation state:** stopped (paused).
- **Assets root:** Isaac Sim 5.1 asset bundle.

## Success criteria
1. Connection to Isaac Sim is confirmed.
2. The LIMO robot is found by traversal (not by hardcoded path).
3. The four wheel joints (`front_left_wheel`, `front_right_wheel`, `rear_left_wheel`, `rear_right_wheel`) are surfaced with their type (revolute), current position, target, stiffness, damping, and limits.
4. Any non-obvious drive-config detail is flagged to the user.

## Cross-references
- **Transcript:** `../orchestration_logs/06_connect_limo_show_topics.md`
- **Tool-call trace:** `../orchestration_logs/06_connect_limo_show_topics.jsonl`
- **UI artifact (joint topics table):** `../orchestration_logs/06_connect_limo_show_topics_joint_topics.html`
- **Scoring:** `../evaluation_notes/06_connect_limo_show_topics.md`
