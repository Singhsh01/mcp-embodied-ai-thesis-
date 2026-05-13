# isaac_native_experiment / screenshots — index

All recordings of the simulation-native (Isaac Sim MCP) experiment live here. There are two recording campaigns: the **Task 1–5** prompt set (general agent behaviour) and the **Franka pick-and-place** repeatability runs.

## Task prompt runs

| Folder | Source video | What it shows |
| ------ | ------------ | ------------- |
| `task_01/` | `uploads/Task 1.webm` | Task 1 prompt run, driven by the Isaac Sim MCP server (no middleware). |
| `task_02/` | `uploads/Task 2.webm` | Task 2 prompt run. |
| `task_03/` | `uploads/Task 3.webm` | Task 3 prompt run. |
| `task_05/` | `uploads/Task 5.webm` | Task 5 prompt run. (No Task 4 recording was uploaded.) |

## Franka pick-and-place — repeatability study

| Folder | Source video | What it shows |
| ------ | ------------ | ------------- |
| `franka_pick_place_01/` | `uploads/Frankapickand place1.mp4` | Run 1 of the same pick-and-place task. |
| `franka_pick_place_02/` | `uploads/Frankapickand place2.mp4` | Run 2. |
| `franka_pick_place_03/` | `uploads/Frankapickand place3.mp4` | Run 3. |
| `franka_pick_place_04/` | `uploads/Frankapickand place4.mp4` | Run 4. |
| `franka_pick_place_05/` | `uploads/Frankapickand place5.mp4` | Run 5. |

## Per-folder contents

Each subfolder contains:

- `frame_00_start.png`, `frame_25_quarter.png`, `frame_50_half.png`, `frame_75_threequarter.png`, `frame_99_end.png` — five keyframes spaced across the clip.
- `contact_sheet.png` — single 5-tile strip image, suitable as a thesis figure.
- `preview.gif` — ~6-second 480p looping clip for inline embedding.
- `README.md` — auto-generated per-folder description.

## How these support the thesis

- The four **Task** runs feed the qualitative-evaluation section: prompt design, tool-call traces, failure modes, agent self-correction. Cross-link them from `../evaluation_notes/NN_*.md`.
- The five **Franka pick-and-place** runs are a small repeatability study disguised as five videos. Together they let you make three claims the single-run middleware experiment cannot: (a) repeatability of the simulation-native pipeline across runs, (b) a failure-mode taxonomy if any run differs, and (c) an empirical "intent → effect" wall-clock latency distribution that you can contrast against the rosbridge-measured latency on the middleware side.

## Where to cite each asset

- *Thesis body*: one representative frame per task (typically `frame_50_half.png` or `frame_75_threequarter.png`) plus the Franka `contact_sheet.png` you judge most representative.
- *Appendix*: full keyframe sets and `preview.gif` for every run, plus a small per-task repeatability table aggregating across the five Franka runs.
- *Supplementary archive*: the original source videos (gitignored, not committed).
