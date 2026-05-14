# protocol.md — Isaac Sim native experiment

This folder records round-trip-time measurements for tool calls that traverse
the **LLM → MCP server → Isaac Sim Kit Python** pipeline. The aggregated
numbers feed the latency table in the thesis.

This document supplements `../../reproducibility_guide.md §6`. The
ROS-middleware experiment's protocol assumes a rosbridge WebSocket hop; the
native experiment does **not** have that hop, so the schema is reduced from
four spans to three.

## Pipeline under measurement

```
  [LLM]                    [MCP server]                          [Isaac Sim Kit]
    |                            |                                     |
    | tool_call                  |                                     |
    | (JSON-RPC over             |                                     |
    |  stdio/SSE)                |                                     |
    |--------------------------->|                                     |
    |       T0                   | T1                                  |
    |                            | dispatch to USD / OmniGraph /       |
    |                            | physics / sensor / renderer         |
    |                            |------------------------------------>|
    |                            |                                     | T2
    |                            |                                     | (handler
    |                            |                                     |  returns)
    |                            | T3                                  |
    |                            | result serialised, sent back        |
    |<---------------------------|                                     |
    |       T4                   |                                     |
```

Three time spans are recorded (plus end-to-end):

| Span | Definition |
| --- | --- |
| `t_llm_to_mcp_ms`     | T1 − T0. JSON-RPC arrival timestamp at the MCP server minus the LLM client's `request_sent` timestamp. |
| `t_mcp_to_kit_ms`     | T2 − T1. Kit handler entry timestamp minus the MCP server's outbound timestamp. Captures cross-process IPC + handler dispatch. |
| `t_kit_handler_ms`    | (handler-internal). Time spent executing the actual USD/OmniGraph/physics/sensor work, from handler entry to handler return. Reported separately because it dominates total latency for `step_simulation` and `execute_script`. |
| `t_total_ms`          | T4 − T0. End-to-end as seen by the LLM client. Not equal to the sum of the three spans (the return path adds a fourth, smaller span; see below). |

## Why three spans, not four

The ROS-middleware experiment has a rosbridge WebSocket between the MCP server
and the eventual ROS process; that's a measurable cross-process hop with its
own queueing. The native experiment's MCP server speaks **directly to Kit**
via either the Kit Python REPL or an in-process extension. There is one IPC
boundary (MCP server process → Kit process), not two. Combining `t_mcp_to_kit`
+ `t_kit_handler` into a single span would hide the dominant cost; splitting
them gives the thesis a fair "MCP overhead vs. work done" decomposition.

The return-path span (T4 − T3 minus T2 − T1, roughly) is not separately
sampled because it has no policy content — it's just the serialised result
size divided by IPC bandwidth. Where it exceeds 50 ms (mostly the
`capture_image` payload and `list_prims` on dense scenes), the row is
flagged with `return_dominated=true` in the CSV.

## Clock conventions

- **All durations are reported in milliseconds with a single decimal place.**
- **Per-process timestamps are `time.monotonic_ns()`** for within-process
  durations (e.g. `t_kit_handler_ms`).
- **Cross-process spans** use **wall clock
  (`time.clock_gettime(CLOCK_REALTIME)`) on each side**. The MCP server
  process and the Kit process are co-located on the same host
  (`/home/sing/`), so chrony-style NTP skew is not relevant — both
  processes read the same kernel clock. Residual jitter is sub-microsecond
  and ignored.
- **`t_kit_handler_ms`** is captured by wrapping each Kit-side handler in a
  decorator that records entry/exit timestamps. The decorator is part of
  the measurement harness, not the production MCP server.

## Sampling discipline

- Each tool is sampled at least **n = 30 times** under steady-state load
  (Isaac Sim running, simulation paused unless the tool requires
  otherwise, no other clients on the MCP server).
- The first **5 warm-up calls** of each session are excluded from the
  aggregate. Kit's first call to any tool incurs measurable lazy-import and
  module-resolution cost — especially `execute_script` (first compile),
  `capture_image` (first render-product attach), and any
  `isaacsim.sensors.*` call (first sensor wrapper construction).
- Outliers > p99.5 are kept in `raw/` and flagged in `aggregated.md`.

## What the experiment actually measured

> **Honest note for the thesis chapter.** The chat sessions in
> `../orchestration_logs/` did not include latency instrumentation. The
> CSVs in `raw/` reflect a follow-up dedicated measurement run that
> replays the same tool sequences with the instrumentation described
> above. The replay uses the scripts in `../generated_scripts/` and the
> tool sequences in `../orchestration_logs/*.jsonl` so the workload
> matches what the agent ran in-session.
>
> Two failure-mode tools (`capture_image` on this server; pre-fix
> `edit_action_graph` semantics) cannot be sampled at all in their failing
> configurations — the calls don't return useful work, so any latency
> number for them is misleading. Those rows are present in
> `aggregated.md` with `failed=true` and the failure mode quoted from
> the orchestration logs.

## CSV schema (`raw/NN_taskID_short_slug.csv`)

| Column | Type | Notes |
| --- | --- | --- |
| `sample_idx` | int | 0-indexed; warm-ups have `warmup=true` |
| `warmup` | bool | true for the first 5 calls of a session |
| `tool_name` | string | e.g. `isaac-sim:step_simulation` |
| `op` | string | `info` / `exec` / `mutate` / `render` |
| `arg_key` | string | salient argument for stratification, e.g. `num_steps=180` |
| `t_llm_to_mcp_ms` | float | ms |
| `t_mcp_to_kit_ms` | float | ms |
| `t_kit_handler_ms` | float | ms; handler-internal work |
| `t_total_ms` | float | ms; end-to-end LLM-client perspective |
| `return_dominated` | bool | true if return-path payload > 50 ms |
| `failed` | bool | true if the tool returned an error (still timed, but excluded from aggregate) |
| `note` | string | free text; used for outliers and failure modes |
