# evaluation_notes/ — Isaac Sim native experiment

Qualitative scoring and observations for each task in the simulation-native pipeline.

**Recommended format:** one Markdown file per task, plus one summary `summary.md` aggregating the table at the end.

For each task, record:

| Field | Description |
| ----- | ----------- |
| Task ID | Matches the prompt file. |
| Outcome | `success` / `partial` / `failure`. |
| Number of tool calls | Total MCP tool invocations. |
| Self-corrections | Times the agent recovered from a failed tool call. |
| Failure mode (if any) | e.g. wrong API used, hallucinated argument, scene-state mismatch. |
| Notable observations | Free text — what surprised you, what was elegant, what was brittle. |

These notes feed directly into the qualitative-evaluation section of the thesis.
