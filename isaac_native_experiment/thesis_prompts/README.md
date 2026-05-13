# thesis_prompts/ — Isaac Sim native experiment

Store one Markdown file per task issued to the LLM agent during the simulation-native experiment.

**Naming convention:** `NN_short_slug.md` (e.g. `01_spawn_cube_on_table.md`).

**Each prompt file should contain:**

1. **Task ID** and one-line goal.
2. **Verbatim prompt** sent to Claude (no rewriting after the run).
3. **Initial scene state** (USD file, objects already present, simulation paused/playing).
4. **Success criteria** — what counts as the task being completed.
5. **Cross-references** — which transcript in `../orchestration_logs/`, which screenshots in `../screenshots/`, which scoring in `../evaluation_notes/`.

Keep prompts immutable after the run so the experiment remains reproducible.
