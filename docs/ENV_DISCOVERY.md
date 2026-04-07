# ENV_DISCOVERY.md

## What This Is

This document explains how the Agent Factory template detects and adapts to different runtime environments.

---

## How survey_environment.sh Works

`s scripts/survey_environment.sh` is the environment detection engine. It runs during `create_project.sh` (Step 3) and generates `config/ENV_PROFILE.json`.

### Detection Sequence

#### 1. Detect Environment Type

```bash
# Checks performed:
# - Is /volume2 present? (NAS indicator)
# - Is docker command available?
# - Is docker daemon running?
```

| Detected Value | Conditions |
|----------------|-----------|
| `nas_docker` | `/volume2` exists AND docker is available |
| `docker` | docker is available, but `/volume2` does not exist |
| `python_only` | python3 is available, no docker |
| `unknown` | none of the above (fallback) |

#### 2. Detect Executor

```bash
# Checks: command -v qwen → command -v python3 → command -v bash
```

| Detected Value | Condition |
|----------------|----------|
| `qwen` | `qwen` CLI is in PATH |
| `python3` | `python3` is in PATH |
| `bash` | only `bash` is available |
| `unknown` | nothing detected |

#### 3. Detect Git

```bash
command -v git
```

Returns: `available` or `unavailable`

#### 4. Detect Docker

```bash
# Two-step check:
# 1. Is docker command available?
# 2. Is docker daemon running? (docker ps)
```

Returns: `available`, `daemon_not_running`, or `unavailable`

#### 5. Detect Gateway Port

```bash
# Checks if port 18080 is already in use
# Uses ss or netstat to detect listening ports
# If 18080 is busy, defaults to 18081
```

Returns: `18080` or `18081` (or another available port)

#### 6. Detect OpenClaw Container

```bash
docker ps --filter "name=openclaw" --format '{{.Names}}' | head -1
```

Returns: container name (e.g. `openclaw001`) or `none_detected`

#### 7. Auto-Select Bootstrap Mode

Based on detected executor:

| Executor | Auto-selected Mode |
|----------|-------------------|
| `qwen` | `qwen` |
| `python3` / `bash` | `manual` |
| `unknown` | `manual` |

---

## ENV_PROFILE.json Fields

After detection, `config/ENV_PROFILE.json` contains:

```json
{
  "project_name": "ppt_agent_factory",
  "project_root": "/volume2/qa/projects/ppt_agent_factory",
  "environment": "nas_docker",
  "bootstrap.mode": "qwen",
  "executor": "qwen",
  "gateway.port": "18081",
  "gateway.host": "0.0.0.0",
  "openclaw.container": "openclaw001",
  "created_at": "2026-04-07T14:24:00+00:00"
}
```

### Field Descriptions

| Field | Source | Purpose |
|-------|--------|---------|
| `project_name` | Derived from directory name | Display name for the instance |
| `project_root` | Absolute path to project | Used by all scripts as base path |
| `environment` | Auto-detected | Tells scripts what environment they're running in |
| `bootstrap.mode` | Auto-selected or overridden | Controls entrypoint behavior |
| `executor` | Auto-detected | Tells scripts which executor to use |
| `gateway.port` | Auto-detected (port conflict check) | Port for ppt-gateway service |
| `gateway.host` | Default | Host binding for ppt-gateway |
| `openclaw.container` | Auto-detected via docker ps | OpenClaw container name for interaction |
| `created_at` | Current timestamp | When this instance was created |

---

## How to Manually Modify ENV_PROFILE.json

If auto-detection is incorrect or you need to override:

### Method 1: Edit the Generated File

```bash
python3 -c "
import json
cfg = json.load(open('config/ENV_PROFILE.json'))
cfg['bootstrap.mode'] = 'manual'
cfg['executor'] = 'python3'
json.dump(cfg, open('config/ENV_PROFILE.json', 'w'), indent=2)
"
```

### Method 2: Start From Template

```bash
# Copy template and fill in manually
cp config/ENV_PROFILE.template.json config/ENV_PROFILE.json

# Then edit with actual values:
python3 -c "
import json
cfg = json.load(open('config/ENV_PROFILE.json'))
cfg['project_name'] = 'my_project'
cfg['project_root'] = '/path/to/my_project'
cfg['environment'] = 'docker'
cfg['bootstrap.mode'] = 'manual'
cfg['executor'] = 'python3'
cfg['gateway.port'] = '18080'
cfg['openclaw.container'] = 'openclaw001'
json.dump(cfg, open('config/ENV_PROFILE.json', 'w'), indent=2)
"
```

### Method 3: Re-run Detection

```bash
bash scripts/survey_environment.sh /path/to/project
```

This will overwrite `ENV_PROFILE.json` with fresh detection results.

---

## What Happens If Detection Fails

The script **never fails**. It always degrades gracefully:

| Failure | Degradation |
|---------|-------------|
| No docker | `environment: "python_only"`, `docker: "unavailable"` |
| No qwen | `executor: "python3"` or `"bash"` |
| No git | `git: "unavailable"` (non-blocking) |
| No ss/netstat | Port defaults to 18080 |
| Template missing | Minimal ENV_PROFILE.json generated from scratch |
| python3 unavailable | Script exits with error (hard dependency) |

---

## Example: Typical Outputs

### NAS Environment

```json
{
  "project_name": "ppt_agent_factory",
  "project_root": "/volume2/qa/projects/ppt_agent_factory",
  "environment": "nas_docker",
  "bootstrap.mode": "qwen",
  "executor": "qwen",
  "gateway.port": "18081",
  "gateway.host": "0.0.0.0",
  "openclaw.container": "openclaw001",
  "created_at": "2026-04-07T14:24:00+00:00"
}
```

### Minimal Environment (no docker, no qwen)

```json
{
  "project_name": "my_project",
  "project_root": "/home/user/my_project",
  "environment": "python_only",
  "bootstrap.mode": "manual",
  "executor": "python3",
  "gateway.port": "18080",
  "gateway.host": "0.0.0.0",
  "openclaw.container": "none_detected",
  "created_at": "2026-04-07T14:24:00+00:00"
}
```