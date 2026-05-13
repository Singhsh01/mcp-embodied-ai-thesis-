# ros_middleware_experiment / screenshots — index

The middleware-centric (ROS-MCP + rosbridge + LIMO) experiment is documented here.

| Folder | Source video | What it shows |
| ------ | ------------ | ------------- |
| `limo_overview/` | `uploads/Untitled design.mp4` | LIMO scene driven through the ROS-MCP middleware pipeline in Isaac Sim. Serves as the visual baseline / figure context for the middleware experiment chapter. |

> Note: the four `Task N.webm` recordings (Task 1, 2, 3, 5) belong to the **simulation-native** experiment, not this one. They live under `../../isaac_native_experiment/screenshots/task_0N/`.

## Per-folder contents

`limo_overview/` contains:

- `frame_00_start.png`, `frame_25_quarter.png`, `frame_50_half.png`, `frame_75_threequarter.png`, `frame_99_end.png` — five keyframes spaced across the clip.
- `contact_sheet.png` — single 5-tile strip image, suitable as a thesis figure.
- `preview.gif` — ~6-second 480p looping clip for inline embedding.
- `README.md` — auto-generated per-folder description.

## How this supports the thesis

The single overview clip serves three purposes:

1. **Figure context** for the middleware-experiment chapter — the "this is what the LIMO scene looks like" shot.
2. **Topic-graph evidence** — frames typically include the Isaac Sim viewport plus, when visible, the ROS 2 topic list / rosbridge console; preserves proof the middleware path was active.
3. **Anchor for latency annotation** — pair the frames with the per-tool latency CSVs under `../latency_notes/raw/` to build the latency breakdown figure.

## Where to cite each asset

- *Thesis body*: `contact_sheet.png` as the figure that introduces the LIMO scene; one keyframe (typically `frame_50_half.png`) inline near the latency-breakdown chart.
- *Appendix*: all five keyframes plus the `preview.gif`.
- *Supplementary archive*: the original source video (gitignored, not committed).

When you add per-task LIMO experiments in the future, give each one its own `task_NN/` subfolder under this directory, following the same naming convention used in the isaac-native experiment.
