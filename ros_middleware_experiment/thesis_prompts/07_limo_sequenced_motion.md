# 07 — Sequenced motion: forward / backward / turn right

## Task ID & goal
**Task ID:** `07_limo_sequenced_motion`
**One-line goal:** Drive the LIMO robot through a three-phase sequence — forward for 3 s, backward for 4 s, turn right for 2 s — using direct wheel-velocity commands.

## Verbatim prompt sent to Claude
> Make the robot move forward for 3 seconds, then move backward for 4 seconds and then finally turn right for 2 seconds

## Initial scene state
- **USD file:** `limo_example.usd` (unchanged from task 06).
- **Robot:** `/Root/limo_ROS`, 4-DOF differential-drive, velocity-drive mode (stiffness=0, damping=1e6).
- **Simulation state:** paused at task start.

## Success criteria
1. The agent recognises the robot as differential-drive and drives it via wheel velocities, not body twists.
2. Sequence executes in order: forward → backward → turn right → stop, with the correct durations.
3. Wheel-sign convention is internally consistent (forward-left and forward-right wheels rotate in opposite signs because the wheels face outwards on a diff-drive base).
4. After the final stop command, all joint velocities settle near zero.
5. No physics errors during the 9 s sequence.

## Cross-references
- **Transcript:** `../orchestration_logs/07_limo_sequenced_motion.md`
- **Tool-call trace:** `../orchestration_logs/07_limo_sequenced_motion.jsonl`
- **Generated script:** `../generated_scripts/07_limo_sequenced_motion_drive_sequence.py`
- **Scoring:** `../evaluation_notes/07_limo_sequenced_motion.md`
