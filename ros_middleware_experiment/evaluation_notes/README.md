# evaluation_notes/ — ROS-middleware experiment

Qualitative scoring and observations for each task in the middleware-centric pipeline. Mirror the structure used in `isaac_native_experiment/evaluation_notes/` so the two pipelines remain directly comparable.

Per task, record:

| Field | Description |
| ----- | ----------- |
| Task ID | Matches the prompt file. |
| Outcome | `success` / `partial` / `failure`. |
| Number of tool calls | Total MCP tool invocations. |
| Self-corrections | Times the agent recovered from a failed tool call. |
| Failure mode (if any) | Hallucinated topic name, wrong message type, missing service, rosbridge timeout, etc. |
| Notable observations | What did the middleware help with, what did it get in the way of? |

A `summary.md` should aggregate the per-task table for the thesis discussion section.
