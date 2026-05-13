# thesis_prompts/ — ROS-middleware experiment

Store one Markdown file per task issued to the LLM agent during the middleware-centric experiment.

**Naming convention:** `NN_short_slug.md`.

To keep the two experiments directly comparable, **issue the same task set** as in `isaac_native_experiment/thesis_prompts/` wherever the task is physically meaningful for the LIMO robot. Where a task only makes sense for one pipeline, note that explicitly in the prompt file header.

Each prompt file should record:

1. Task ID and one-line goal.
2. Verbatim prompt sent to Claude.
3. Initial robot state (pose, scene, which Isaac Sim USD).
4. Success criteria.
5. Cross-references to `../orchestration_logs/`, `../screenshots/`, `../latency_notes/`, `../evaluation_notes/`.
