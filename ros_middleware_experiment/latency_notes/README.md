# latency_notes/ — ROS-middleware experiment

Round-trip-time measurements for the middleware-centric pipeline. This folder is the source of the latency table in the thesis.

**Suggested files:**

- `protocol.md` — your exact measurement procedure (already described in `../../reproducibility_guide.md §6`; copy or extend it here with any local adjustments).
- `raw/` — per-run CSVs (`NN_taskID_short_slug.csv`), one row per sampled tool call with columns:
  - `tool_name`
  - `t_llm_to_mcp_ms`
  - `t_mcp_to_rosbridge_ms`
  - `t_rosbridge_to_ros_ms`
  - `t_total_ms`
- `aggregated.md` — summary table (median, p95, max, n) per tool, used directly in the thesis.

Be explicit about wall-clock vs monotonic clocks, and about which side of the rosbridge WebSocket the timestamps were captured on.
