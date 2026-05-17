# Attribution

This thesis workspace experimentally reproduces and evaluates two existing open-source projects. Their original authors retain full copyright; the projects are redistributed inside this workspace under the terms of their respective licenses, with all LICENSE files preserved unchanged in their original locations.

This file exists so that any reviewer of the thesis or any downstream user of this archive can, in one place, see exactly what was reproduced, who authored it, and what the thesis itself contributes on top.

---

## 1. Upstream projects reproduced

### 1.1 isaacsim-mcp-server

| Field | Value |
| ----- | ----- |
| Location in this workspace | `isaac_native_experiment/isaacsim-mcp-server-main/` |
| License | MIT |
| Copyright | © 2023–2025 omni-mcp; © 2026 whats2000 |
| License file | `isaac_native_experiment/isaacsim-mcp-server-main/LICENSE` |
| Role in this thesis | Provides the **simulation-native** orchestration pipeline. The LLM agent connects directly to this MCP server, which acts on the running Isaac Sim / Omniverse Kit application. |
| Modifications | None. The repository is included verbatim. |

### 1.2 ros-mcp-server

| Field | Value |
| ----- | ----- |
| Location in this workspace | `ros_middleware_experiment/ros_mcp_server/` (server core) and `ros_middleware_experiment/original_limo_example/` (the LIMO Isaac Sim example) |
| License | Apache License 2.0 |
| Copyright | © Rohit John Varghese, Jungsoo Lee, Youngmok Yun, Stefano Dalla Gasperina |
| License file | `ros_middleware_experiment/ros_mcp_server/LICENSE` |
| Role in this thesis | Provides the **middleware-centric** orchestration pipeline. The LLM agent connects to this MCP server, which speaks to rosbridge against a ROS 2 Humble graph running the AgileX LIMO robot in Isaac Sim. |
| Modifications | None to the source files that were retained. The upstream `examples/` tree (apart from the limo Isaac-Sim example), the upstream `tests/` tree, and the upstream `docs/` site were intentionally not vendored into this workspace; this is documented in `ros_middleware_experiment/ros_mcp_server/PROVENANCE.md`. The license terms are unaffected by this curation — only the size of the redistribution is reduced. |

---

## 2. What this thesis contributes

The thesis contribution is **explicitly not** the two servers above. The contribution is:

1. **Side-by-side reproduction** of both pipelines on the same workstation, the same Isaac Sim version, and (wherever physically meaningful) the same simulated robot scene — so that any difference in behaviour is attributable to the orchestration architecture rather than to environmental drift.
2. **Architectural comparison** between simulation-native and middleware-centric MCP orchestration, formalized through the diagrams in `diagrams/` and discussed in the thesis body.
3. **Orchestration-layer evaluation**: prompt design, MCP tool-call traces, agent self-correction behaviour, failure-mode taxonomy. Per-task evidence lives under each experiment's `orchestration_logs/` and `evaluation_notes/`.
4. **Latency analysis** of the middleware-centric pipeline (decomposed into agent → MCP, MCP → rosbridge, rosbridge → ROS hops).
5. **Two recording campaigns on the simulation-native pipeline**: a four-task prompt set (`isaac_native_experiment/screenshots/task_0{1,2,3,5}/`) that feeds the qualitative-evaluation section, and a five-run **repeatability study** of the same Franka pick-and-place task (`isaac_native_experiment/screenshots/franka_pick_place_0{1..5}/`) that supports the per-run variance discussion.


Items 1–6 are original work for this thesis; items 1–5 build on top of the upstream servers without modifying them.

---

## 3. Compliance notes (do not strip these files)

Both upstream licenses **require** that the copyright notice and license text be retained when their code is redistributed.

- **MIT** (isaacsim-mcp-server): "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software."
- **Apache 2.0** (ros-mcp-server): Section 4 requires retaining the license, the copyright notice, and any attribution notices that accompanied the original.

Concretely, this means the following files **must not** be deleted from the workspace:

- `isaac_native_experiment/isaacsim-mcp-server-main/LICENSE`
- `isaac_native_experiment/isaacsim-mcp-server-main/LICENSE_README.md`
- `isaac_native_experiment/isaacsim-mcp-server-main/LICENSE_HEADER.py`
- `ros_middleware_experiment/ros_mcp_server/LICENSE`
- `ros_middleware_experiment/ros_mcp_server/README.md` (contains upstream attribution)
- `ros_middleware_experiment/original_limo_example/README.md` (contains upstream attribution for the limo example)
- `ros_middleware_experiment/ros_mcp_server/PROVENANCE.md` (documents what was vendored and what was dropped)

Removing any of the above would (a) violate the relevant license, and (b) misrepresent the boundary between the upstream authors' work and the thesis's own contribution. Neither is acceptable.

---

## 4. Citing this work

If a reader of this thesis wants to cite the underlying open-source projects independently:

- *isaacsim-mcp-server*, omni-mcp and whats2000, MIT-licensed. See `isaac_native_experiment/isaacsim-mcp-server-main/README.md` for the project description and any preferred citation form.
- *ros-mcp-server*, Rohit John Varghese, Jungsoo Lee, Youngmok Yun, Stefano Dalla Gasperina, Apache-2.0-licensed. See `ros_middleware_experiment/ros_mcp_server/README.md`.

If a reader wants to cite *this thesis*, cite the thesis itself; do not cite this workspace as if it were the upstream project.

---

## 5. Optional: upstream URLs

The upstream public URLs for both projects were not captured in the vendored snapshots. If you intend to host this workspace publicly (e.g. on a thesis repository or institutional archive), fill in the placeholders below from the corresponding GitHub project pages before publishing.

- isaacsim-mcp-server: `https://github.com/<org>/isaacsim-mcp-server` *(fill in)*
- ros-mcp-server: `https://github.com/<org>/ros-mcp-server` *(fill in)*
