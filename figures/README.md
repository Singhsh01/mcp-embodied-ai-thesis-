# figures/

Polished figures used directly inside the thesis PDF. Distinguish these from `../diagrams/` (which holds the architectural drawings) and from each experiment's `screenshots/` folder (which holds raw evidence).

A figure in this folder typically combines material from multiple raw sources — e.g. a 2×2 grid of screenshots with captions, or a chart generated from a CSV in `../ros_middleware_experiment/latency_notes/raw/`.

**Recommended structure:**

```
figures/
├── thesis_body/          ← figures cited in the main thesis text
├── appendix/             ← figures cited only in the appendix
└── supplementary/        ← anything kept for the supplementary archive
```

For every figure, keep both a high-resolution version (`.pdf` or `.png` ≥ 300dpi) and, where applicable, the script or notebook that generated it (e.g. `01_latency_box_plot.py`).

**Curation guide — what goes where:**

- **Thesis body:** the overall architecture diagram, one screenshot per pipeline showing the robot acting, the latency comparison chart, the qualitative scoring table.
- **Appendix:** the full task-by-task screenshot matrix, full transcript excerpts, prompt phrasing experiments.
- **Supplementary:** raw videos, full `ros2 bag` recordings, expanded log dumps.
