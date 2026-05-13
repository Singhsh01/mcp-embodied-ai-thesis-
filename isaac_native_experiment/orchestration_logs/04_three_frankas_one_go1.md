# 04 — Three Frankas + one Go1 — transcript

> Source chat date: 2026-05-13. Continues from task 03.

## Verbatim prompt
> Create three Franka robots in a row at [0,0,0], [2,0,0], and [4,0,0].
> Then add a Go1 robot at [1, 3, 0].

## Turn-by-turn summary

### T1 — tool discovery
- Agent searched the tool surface for robot-creation tooling (`list_available_robots`, `create_robot`).

### T2 — three Frankas
- `isaac-sim:create_robot(robot_type=franka, prim_path=/World/Franka_1, position=[0,0,0])` → success, 9 DOF, joints prefixed `fr3_*`.
- `isaac-sim:create_robot(robot_type=franka, prim_path=/World/Franka_2, position=[2,0,0])` → success, identical signature.
- `isaac-sim:create_robot(robot_type=franka, prim_path=/World/Franka_3, position=[4,0,0])` → success, identical signature.

Agent flagged unprompted: **"franka" resolved to the Franka FR3 (Isaac 5.1 default), not the older Panda**, so joint names use the `fr3_` prefix. This is the same model that caused the RMPflow preset issue in the other session — the agent surfaces the model identity proactively here.

### T3 — Go1 quadruped
- `isaac-sim:create_robot(robot_type=go1, prim_path=/World/Go1, position=[1,3,0])` → success, 12 DOF.

### T4 — proactive diagnostic
Agent flagged drive warnings without being asked:

> Heads-up on the drive warnings: every Franka has `fr3_finger_joint2` reporting stiffness=damping=0, and every Go1 joint reports the same. On the Frankas this is normal — `fr3_finger_joint2` is the mimic finger driven by `fr3_finger_joint1`. On the Go1, though, all 12 joints having zero gains means it won't hold a pose or respond to position targets out of the box — it'll collapse the moment physics starts. If you want it to stand, we'll need to set joint drive stiffness/damping (something like ~50/5 for hips and thighs, ~30/3 for calves is a typical starting point). Want me to configure those drives before you press play?

Also flagged that `/World/WorkspaceCamera` from task 03 is currently centered on Franka_1 and offered to reposition it to capture the wider scene.

## Final state
| Path | Position | DOF | Notes |
| --- | --- | --- | --- |
| `/World/Franka_1` | [0, 0, 0] | 9 | FR3, fr3_finger_joint2 mimic-warning (benign) |
| `/World/Franka_2` | [2, 0, 0] | 9 | identical |
| `/World/Franka_3` | [4, 0, 0] | 9 | identical |
| `/World/Go1` | [1, 3, 0] | 12 | **all joints have stiffness=damping=0** — won't stand on play unless drives are tuned |

No tool errors. No self-corrections. The agent did *zero* unrequested actions but did *two* unrequested warnings, which is the right balance.
