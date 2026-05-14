# aggregated.md — Isaac Sim native experiment

Aggregation over all sampled rows in `raw/`. **All values in milliseconds.**
n is the number of non-warm-up samples; warm-ups are reported separately.

## Status

The orchestration logs in `../orchestration_logs/` are conversational
traces, not instrumented runs. Filling this table to the standard required
by the thesis requires the **dedicated replay pass** described in
`protocol.md` — issuing the same tool sequences through a measurement
harness with per-process timestamps. Until that replay exists, the rows
below are placeholders with the expected schema.

Where a tool's wall-clock floor is determined by physics-frame count
(`step_simulation`), that floor is given as the expected lower bound.

## Per-tool aggregate (pending replay)

| Tool | n (non-warmup) | median total | p95 total | max total | Notes |
| --- | ---: | ---: | ---: | ---: | --- |
| `isaac-sim:get_scene_info` | _pending_ | _pending_ | _pending_ | _pending_ | trivial info call |
| `isaac-sim:list_prims` | _pending_ | _pending_ | _pending_ | _pending_ | scales with prim count + traversal depth |
| `isaac-sim:get_prim_info` | _pending_ | _pending_ | _pending_ | _pending_ | per-prim USD read |
| `isaac-sim:get_robot_info` | _pending_ | _pending_ | _pending_ | _pending_ | |
| `isaac-sim:get_joint_state` | _pending_ | _pending_ | _pending_ | _pending_ | |
| `isaac-sim:get_simulation_state` | _pending_ | _pending_ | _pending_ | _pending_ | |
| `isaac-sim:get_physics_state` | _pending_ | _pending_ | _pending_ | _pending_ | |
| `isaac-sim:get_isaac_logs` | _pending_ | _pending_ | _pending_ | _pending_ | scales with log buffer size |
| `isaac-sim:create_physics_scene` | _pending_ | _pending_ | _pending_ | _pending_ | |
| `isaac-sim:create_object` | _pending_ | _pending_ | _pending_ | _pending_ | with vs. without physics enabled |
| `isaac-sim:create_robot` | _pending_ | _pending_ | _pending_ | _pending_ | first call cold-loads URDF; warm-up dominated |
| `isaac-sim:create_material` | _pending_ | _pending_ | _pending_ | _pending_ | |
| `isaac-sim:apply_material` | _pending_ | _pending_ | _pending_ | _pending_ | |
| `isaac-sim:create_light` | _pending_ | _pending_ | _pending_ | _pending_ | |
| `isaac-sim:create_camera` | _pending_ | _pending_ | _pending_ | _pending_ | |
| `isaac-sim:create_action_graph` | _pending_ | _pending_ | _pending_ | _pending_ | OmniGraph + ScriptNode setup |
| `isaac-sim:edit_action_graph` | _pending_ | _pending_ | _pending_ | _pending_ | report transient-vs-durable separately |
| `isaac-sim:load_environment` | _pending_ | _pending_ | _pending_ | _pending_ | asset reference resolution; expected long tail |
| `isaac-sim:list_environments` | _pending_ | _pending_ | _pending_ | _pending_ | |
| `isaac-sim:list_available_robots` | _pending_ | _pending_ | _pending_ | _pending_ | |
| `isaac-sim:play_simulation` | _pending_ | _pending_ | _pending_ | _pending_ | |
| `isaac-sim:pause_simulation` | _pending_ | _pending_ | _pending_ | _pending_ | |
| `isaac-sim:clear_scene` | _pending_ | _pending_ | _pending_ | _pending_ | |
| `isaac-sim:step_simulation` | _pending_ | _pending_ | _pending_ | _pending_ | **floor = n_frames × 16.67 ms**; report overhead above floor separately |
| `isaac-sim:execute_script` | _pending_ | _pending_ | _pending_ | _pending_ | dominated by user-code; report MCP-RPC component separately |
| `isaac-sim:capture_image` | (failing) | n/a | n/a | n/a | **broken on this server**, NoneType error; documented in task 05 |

## Per-span aggregate (pending replay)

| Span | median | p95 | max | Notes |
| --- | ---: | ---: | ---: | --- |
| `t_llm_to_mcp_ms` | _pending_ | _pending_ | _pending_ | JSON-RPC client → server |
| `t_mcp_to_kit_ms` | _pending_ | _pending_ | _pending_ | MCP server process → Kit process IPC |
| `t_kit_handler_ms` | _pending_ | _pending_ | _pending_ | Kit-side work; dominates for step_simulation/execute_script |
| `t_total_ms` | _pending_ | _pending_ | _pending_ | end-to-end |

## Notes for the thesis writer

- **`step_simulation` is real-time-locked.** Its `t_total_ms` is dominated by
  `n_frames × 16.67 ms`. The thesis-relevant number is **overhead above the
  physics floor**, computed as `t_total_ms − n_frames × 16.67`. Report
  that as a separate column in the per-tool table once replay data exists.
- **`execute_script` has a wide variance**: it includes user-code execution
  time, which is highly task-dependent. Report the MCP overhead (compile +
  marshalling) as `t_total_ms − t_kit_handler_ms` separately from the
  user-code component.
- **`capture_image` is broken on this server.** Latency numbers are
  meaningless for failing calls. The row stays in `aggregated.md` for
  visibility but with `n/a` rather than a synthesized number. The
  replacement path via `Camera` sensor API in `execute_script` should be
  measured separately under a synthetic `isaac-sim:capture_image_via_sensor_api`
  label if the bypass is promoted to a tool.
- **First-call costs are real and worth reporting.** Several tools
  (`create_robot`, `load_environment`, `execute_script`, anything touching
  `isaacsim.sensors.*`) have measurable first-call lazy-import or
  asset-resolution overhead. The protocol excludes the first 5 calls as
  warm-ups; report the warm-up cost as a separate `t_first_call_ms`
  metric so readers know what they're paying on a cold start.
- **The MCP/Isaac filesystem split shows up as a failure mode, not a
  latency cost.** Rows where `failed=true` and the note mentions
  filesystem boundary are evidence for the qualitative chapter, not
  inputs to the latency table.
