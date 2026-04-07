# Environment Adaptation Protocol

## Purpose
Define how the Agent Factory template adapts to different runtime environments.

## Detected Environment Types

### nas_docker
- Host system: Synology NAS with Docker
- Project root pattern: `/volume2/ai/`
- Gateway port typically: 18081 (or configurable)
- OpenClaw container typically: openclaw001
- File system: persistent across reboots

### docker
- Generic Docker host (not NAS-specific)
- Requires explicit project root configuration
- Gateway port and container name must be specified

### generic
- Minimal environment detection
- All configuration must be provided manually
- No auto-detection of ports, containers, or executors

## Adaptation Process

1. **Detect environment** via `scripts/survey_environment.sh`
   - Check for `/volume2` (NAS indicator)
   - Check for `docker` command availability
   - Check for `qwen` executor
   - Check for running OpenClaw containers

2. **Generate ENV_PROFILE.json**
   - Fill template placeholders with detected values
   - Default `bootstrap.mode` to `manual` for safety

3. **Validate generated profile**
   - JSON must be parseable
   - Required fields must be present
   - `bootstrap.mode` must be one of: qwen, manual, openclaw_minimal

## ENV_PROFILE Fields

| Field | Source | Example |
|-------|--------|---------|
| `project_name` | Detected from directory name | `ppt_agent_factory` |
| `project_root` | Absolute path | `/volume2/ai/ppt_agent_factory` |
| `environment` | Auto-detected | `nas_docker` |
| `bootstrap.mode` | Default or manual override | `manual` |
| `executor` | Auto-detected | `qwen` |
| `gateway.port` | Detected from config/service | `18081` |
| `gateway.host` | Default | `0.0.0.0` |
| `openclaw.container` | Detected from Docker | `openclaw001` |
| `created_at` | Timestamp | `2026-04-07T17:30:00+08:00` |

## Manual Override

If auto-detection is incorrect or insufficient:
1. Copy `config/ENV_PROFILE.template.json` to `config/ENV_PROFILE.json`
2. Edit values manually
3. Run `scripts/entrypoint.sh` to validate

## Constraints

- Template file (`ENV_PROFILE.template.json`) is never modified
- Only the instantiated `ENV_PROFILE.json` is environment-specific
- All scripts read from `ENV_PROFILE.json`, never from hardcoded values