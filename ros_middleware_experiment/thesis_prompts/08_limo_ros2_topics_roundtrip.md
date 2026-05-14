# 08 — ROS 2 topics: list, classify, subscribe LiDAR, publish cmd_vel, read odom

## Task ID & goal
**Task ID:** `08_limo_ros2_topics_roundtrip`
**One-line goal:** Through the simulator's ROS 2 interface, enumerate topics, identify the camera / LiDAR / velocity-command / odometry topics, check for obstacles in front of the robot, and — if clear — drive forward for 2 s and verify motion via odometry.

## Verbatim prompt sent to Claude
> Connect to the LIMO robot through ROS MCP.
> First, list all available ROS topics and identify which topics correspond to:
>
> 1. camera image data,
> 2. LiDAR scan data,
> 3. robot velocity command,
> 4. robot odometry or pose.
>
> Then subscribe to the LiDAR topic and summarize whether obstacles are visible in front of the robot. If the front area is clear, publish a small forward velocity command to /cmd_vel for 2 seconds, then stop. After stopping, check the odometry topic and report whether the robot moved.

## Initial scene state
- **USD file:** `limo_example.usd` (unchanged).
- **Robot:** `/Root/limo_ROS`, wheels at ~0.277 rad and ~−0.0002 rad/s after task 07's stop. The robot is *not* at the canonical zero pose — it has been driven around.
- **Simulation state:** paused at task start.
- **ROS bridge:** active (the scene is named "ROS" because the publishers/subscribers are wired through the Isaac Sim ROS 2 bridge).

## Success criteria
1. The agent enumerates the live ROS 2 topic list.
2. The agent classifies four topics by purpose without hardcoding topic names ahead of time.
3. LiDAR scan data is sampled and an "obstacles in front?" decision is made from the data, not from a guess.
4. If the front area is judged clear, a forward `/cmd_vel` Twist is published for 2 seconds, then a zero Twist.
5. Odometry is sampled before and after the motion and the displacement is reported.

## Cross-references
- **Transcript:** `../orchestration_logs/08_limo_ros2_topics_roundtrip.md`
- **Tool-call trace:** `../orchestration_logs/08_limo_ros2_topics_roundtrip.jsonl`
- **Generated script:** `../generated_scripts/08_limo_ros2_topics_roundtrip_rclpy_session.py`
- **Scoring:** `../evaluation_notes/08_limo_ros2_topics_roundtrip.md`
