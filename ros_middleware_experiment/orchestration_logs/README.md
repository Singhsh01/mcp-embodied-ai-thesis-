# orchestration_logs/ — ROS-middleware experiment

Captures, per task:

- Full Claude transcript (`NN_taskID_short_slug.md`).
- Optional structured tool-call log (`NN_taskID_short_slug.jsonl`).
- Optional `ros2 bag` summary (`NN_taskID_short_slug.bag.txt`) showing the topics that were active.

The bag itself is gitignored (see `../../.gitignore`); only commit the human-readable summary unless the raw bag is small.

A transcript should include the verbatim prompt, every assistant turn (text + tool calls + tool results), wall-clock timestamps, and any agent recovery from failed tool calls.
