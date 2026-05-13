# orchestration_logs/ — Isaac Sim native experiment

Captures the agent's MCP tool-call traces and full conversation transcripts.

**Naming convention:** `NN_taskID_short_slug.md` (transcript) and `NN_taskID_short_slug.jsonl` (tool calls if exported separately).

A transcript should include:

- The verbatim prompt issued.
- Every assistant turn (text + tool calls + tool results).
- Wall-clock timestamps where available.
- Any agent re-tries or failure recoveries.

These transcripts are the primary evidence for the qualitative evaluation in `../evaluation_notes/`.
