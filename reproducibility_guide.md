# Reproducibility Guide

This guide walks through everything needed to re-run both experiments in this thesis from a clean machine. It targets a single workstation in which Isaac Sim, ROS 2 Humble, and Claude Desktop all run locally and communicate over `localhost`.

> All commands are written assuming you have already cloned this repository into `~/Downloads/Master Thesis` (or any path of your choice). Substitute paths as needed.

---

## 1. Hardware and base system

| Component   | Tested configuration                                             |
| ----------- | ---------------------------------------------------------------- |
| OS          | Ubuntu 22.04 LTS (Jammy)                                         |
| CPU         | x86-64, ≥ 8 cores recommended                                    |
| GPU         | NVIDIA RTX (Ada / Ampere), ≥ 8 GB VRAM                           |
| RAM         | ≥ 32 GB                                                          |
| Storage     | ≥ 80 GB free (Isaac Sim + Omniverse cache)                       |
| NVIDIA driver | 535+ (must satisfy Isaac Sim's minimum)                        |
| CUDA        | 12.x (provided by the NVIDIA driver; no separate install needed) |

> Isaac Sim and ROS 2 Humble both have native Ubuntu 22.04 support, which is why 22.04 is preferred over 20.04 or 24.04.

## 2. Software prerequisites

### 2.1 ROS 2 Humble

```bash
# Add the ROS 2 apt source (see official docs) and then:
sudo apt update
sudo apt install -y ros-humble-desktop ros-humble-rosbridge-suite python3-colcon-common-extensions
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

### 2.2 NVIDIA Omniverse Launcher and Isaac Sim

- Install the **Omniverse Launcher** from NVIDIA.
- Install **Isaac Sim 4.2.0** (or the most recent 4.x release that still ships the ROS 2 bridge extension) through the Launcher.
- Note the install root, typically `~/.local/share/ov/pkg/isaac_sim-4.2.0`.

### 2.3 Python tooling

The ROS-MCP server is a `uv`-managed Python project; the Isaac Sim MCP server uses its own embedded Python. Install `uv`:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 2.4 Claude Desktop

Install **Claude Desktop** for Linux (or run the experiments from a macOS/Windows machine that reaches the simulator over `localhost` via SSH port-forwarding — only `localhost` paths have been validated for this thesis).

## 3. Cloning the workspace

```bash
cd ~/Downloads
# extract or git clone this repository so that the structure documented
# in the top-level README.md is present
ls "Master Thesis"
# README.md   reproducibility_guide.md   isaac_native_experiment/   ros_middleware_experiment/   …
```

## 4. Experiment A — Simulation-native orchestration (Isaac Sim MCP)

### 4.1 Install the Isaac Sim MCP server

The server lives at `isaac_native_experiment/isaacsim-mcp-server-main/`. Follow the install steps inside that folder's own `README.md` — the canonical procedure is:

```bash
cd "isaac_native_experiment/isaacsim-mcp-server-main"
# follow upstream README for installation (pip install -e . or uv sync)
```

### 4.2 Configure Claude Desktop

Edit `~/.config/Claude/claude_desktop_config.json` (Linux) and add the Isaac Sim MCP server:

```json
{
  "mcpServers": {
    "isaacsim": {
      "command": "uv",
      "args": ["--directory", "/ABSOLUTE/PATH/TO/isaac_native_experiment/isaacsim-mcp-server-main", "run", "isaacsim-mcp"]
    }
  }
}
```

Restart Claude Desktop after editing. The exact `command`/`args` should match what the upstream `README` recommends; the above is a template.

### 4.3 Launch order

1. Start **Isaac Sim** and open the desired USD scene.
2. Start the **Isaac Sim MCP extension** (loaded from inside Isaac Sim, per upstream instructions).
3. Open **Claude Desktop** and confirm the `isaacsim` MCP server is connected (look for the tool icons in the input bar).
4. Run a task prompt from `isaac_native_experiment/thesis_prompts/`.
5. Save the conversation transcript to `isaac_native_experiment/orchestration_logs/` and screenshots to `isaac_native_experiment/screenshots/`.

## 5. Experiment B — Middleware-centric orchestration (ROS-MCP + LIMO)

### 5.1 Start the LIMO Isaac Sim scene

```bash
# 1) Open Isaac Sim
# 2) File → Open → ros_middleware_experiment/original_limo_example/usd/limo_example.usd
# 3) In the property panel of the ROS 2 OmniGraph nodes, confirm the topics
#    /cmd_vel, /odom, /scan, /tf, /camera/* are wired and the simulation domain
#    matches your ROS_DOMAIN_ID.
# 4) Press Play to start the simulation.
```

### 5.2 Start rosbridge

In a new terminal:

```bash
source /opt/ros/humble/setup.bash
ros2 launch rosbridge_server rosbridge_websocket_launch.xml
# default port: 9090
```

Sanity-check the LIMO topics are visible:

```bash
ros2 topic list
ros2 topic echo /odom --once
```

### 5.3 Configure and start the ROS-MCP server

```bash
cd "ros_middleware_experiment/ros_mcp_server"
uv sync                  # install Python deps
# Edit robot_specifications/local_rosbridge.yaml if your rosbridge is not on
# localhost:9090, or if you want to constrain the exposed topic surface.
```

Add to `~/.config/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "ros-mcp": {
      "command": "uv",
      "args": ["--directory", "/ABSOLUTE/PATH/TO/ros_middleware_experiment/ros_mcp_server", "run", "ros-mcp-server"],
      "env": {
        "ROS_MCP_ROBOT_SPEC": "/ABSOLUTE/PATH/TO/ros_middleware_experiment/ros_mcp_server/robot_specifications/local_rosbridge.yaml"
      }
    }
  }
}
```

Restart Claude Desktop.

### 5.4 Localhost / networking assumptions

All experiments in the thesis run on a **single workstation** with three local services:

| Service                 | Port             | Reachable at      |
| ----------------------- | ---------------- | ----------------- |
| Isaac Sim               | n/a (GUI)        | `localhost`       |
| rosbridge_websocket     | 9090 (default)   | `ws://localhost:9090` |
| Isaac Sim MCP server    | stdio (spawned)  | via Claude Desktop |
| ROS-MCP server          | stdio (spawned)  | via Claude Desktop |

No firewall rules are required because all traffic is loopback. If you split services across machines, configure `ROS_DOMAIN_ID`, `RMW_IMPLEMENTATION`, and the rosbridge URL accordingly — and re-measure latency, because the thesis numbers will no longer apply.

### 5.5 Task execution workflow

For each task in `ros_middleware_experiment/thesis_prompts/`:

1. Reset the LIMO scene (`Stop` → `Play` in Isaac Sim) so initial conditions are identical across runs.
2. In Claude Desktop, issue the prompt verbatim.
3. While the agent is acting, sample `/cmd_vel` and `/odom` at ≥ 20 Hz via `ros2 bag record -a` and store the bag (or its summary) in `orchestration_logs/`.
4. Save the full Claude transcript to `orchestration_logs/` as Markdown.
5. Note the round-trip latency for at least one representative tool call into `latency_notes/` — see §6.

## 6. Latency measurement protocol

For the middleware-centric experiment the latency of a single tool call decomposes as:

```
T_total  =  T_LLM->MCP  +  T_MCP->rosbridge  +  T_rosbridge->ROS  +  T_ROS->topic
```

The thesis reports `T_MCP→rosbridge` and `T_rosbridge→ROS` independently:

- `T_MCP→rosbridge` — instrument the MCP tool wrapper to log `time.perf_counter()` before and after the `roslibpy`/WebSocket publish call.
- `T_rosbridge→ROS` — compare the rosbridge log timestamp with the `header.stamp` of the resulting ROS 2 message (or with the time the subscriber callback fires, when no `header.stamp` is available).

Record the per-task measurements as a small CSV in `ros_middleware_experiment/latency_notes/`.

## 7. Troubleshooting

| Symptom                                              | Likely cause / fix                                                                                          |
| ---------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| Claude Desktop shows the MCP server "Failed"         | Path in `claude_desktop_config.json` is wrong, or `uv` is not on the user's `PATH` (use an absolute path).  |
| `ros2 topic list` is empty after pressing Play       | The Isaac Sim ROS 2 bridge extension is not enabled, or `ROS_DOMAIN_ID` mismatch between terminals.         |
| rosbridge connects but `/cmd_vel` is ignored         | The Isaac Sim differential drive controller subscribes to a different topic name — check the OmniGraph node.|
| MCP tool calls succeed but the robot doesn't move    | The simulation is paused, or the topic publishes but no controller is downstream.                           |
| High variance in latency measurements                | Other GPU workloads (browsers, recording software) are competing for the GPU — close them before measuring. |

## 8. Cleanup between runs

```bash
# Optional: clear Omniverse cache between sessions if you suspect stale assets
rm -rf ~/.cache/ov/Kit/*
# Stop the simulation in Isaac Sim before quitting (otherwise the next run may
# inherit a stale physics state).
```

## 9. Version pinning summary

| Component           | Pinned version (thesis baseline) |
| ------------------- | -------------------------------- |
| Ubuntu              | 22.04 LTS                        |
| ROS 2               | Humble Hawksbill                 |
| rosbridge_suite     | ros-humble-rosbridge-suite (apt) |
| Isaac Sim           | 5.1.0                            |
| NVIDIA driver       | 535+                             |
| Python (host)       | 3.10                             |
| `uv`                | latest at time of build          |
| Claude Desktop      | latest at time of build          |

If you upgrade any of these, please document the change in your own `evaluation_notes/`.
