# diagrams/

Architecture diagrams used in the thesis body (chapters 2–4 typically).

Keep both the **source** (`.drawio`, `.excalidraw`, `.svg`) and an **exported PNG** for each diagram so co-authors / reviewers can edit, and so the LaTeX build can include the PNG without depending on the drawing tool.

**Recommended naming:** `NN_short_slug.{drawio,svg,png}`.

Suggested initial diagrams:

- `01_overall_architecture.{svg,png}` — both pipelines side-by-side, the same diagram shown on the README cover image.
- `02_isaac_native_pipeline.{svg,png}` — Claude → Isaac Sim MCP → Kit API.
- `03_ros_middleware_pipeline.{svg,png}` — Claude → ROS-MCP → rosbridge → ROS 2 → LIMO.
- `04_tool_call_sequence.{svg,png}` — sequence diagram of a representative task.
- `05_latency_decomposition.{svg,png}` — the latency breakdown chart.

**Belongs in:** thesis body.
