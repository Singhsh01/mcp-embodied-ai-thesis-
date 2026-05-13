# Provenance

These files were extracted from the upstream **ros-mcp-server** project to make the
limo Isaac Sim example reproducible inside this thesis workspace.

Kept:
- server.py, server.json, pyproject.toml, uv.lock, MANIFEST.in, LICENSE, README.md
- ros_mcp/          (the importable package)
- launch/           (rosbridge + MCP server launch helpers)
- robot_specifications/  (YAML robot specs incl. local_rosbridge.yaml)
- config/           (MCP client config templates)

Intentionally dropped (not needed for the thesis experiments):
- examples/        (only 3_limo_mobile_robot/isaac_sim is kept, as ../original_limo_example/)
- tests/           (CI tests, Docker integration tests)
- docs/            (full upstream documentation site)

All copyright and licensing remains with the upstream authors; see ./LICENSE.
