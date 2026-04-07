# Agent Factory Template

## Overview
A templated Agent Factory for automated software development.
Current business instance: PPT Agent.

## Directory Structure

```
/
├── config/
│   ├── template_version.json          # Template metadata and version
│   ├── ENV_PROFILE.template.json      # Environment profile template (in template)
│   └── ENV_PROFILE.json               # Instantiated environment profile (per project)
├── docs/
│   ├── CURRENT_SPRINT.json            # Machine-readable sprint state (SSOT)
│   ├── CURRENT_SPRINT.md              # Human-readable sprint state
│   ├── PROJECT_CONTEXT.md             # Project positioning and rules
│   ├── TASK_RESULT_SCHEMA.md          # Task result field definitions
│   ├── PIPELINE_OVERVIEW.md           # Pipeline structure overview
│   └── TEMPLATE_README.md             # This file
├── skills/
│   ├── project-manager/               # PM decision protocols
│   │   ├── manifest.json
│   │   ├── tools.json
│   │   ├── state_reader.md
│   │   ├── decision_logic.md
│   │   ├── task_delegation.md
│   │   ├── prompt_generator.md
│   │   ├── orchestration_loop.md
│   │   ├── failure_recovery.md
│   │   ├── task_closure.md
│   │   ├── next_task_selection.md
│   │   ├── task_decomposition.md
│   │   ├── acceptance_criteria.md
│   │   ├── task_prioritization.md
│   │   ├── task_dependency_management.md
│   │   ├── task_state_transition.md
│   │   └── task_tracking.md
│   ├── dev/                           # Dev execution protocol
│   │   ├── manifest.json
│   │   ├── tools.json
│   │   └── dev_execution.md
│   ├── qa/                            # QA verification protocol
│   │   ├── manifest.json
│   │   ├── tools.json
│   │   └── qa_verification.md
│   └── project-bootstrap/             # Bootstrap coordination
│       ├── manifest.json
│       ├── tools.json
│       ├── bootstrap_flow.md
│       └── env_adaptation.md
├── services/
│   ├── ppt-gateway/                   # Business entrypoint (mock)
│   │   ├── app/main.py
│   │   ├── requirements.txt
│   │   ├── tests/test_placeholder.py
│   │   └── README.md
│   ├── orchestrator_stub.py           # Placeholder orchestration entrypoint
│   └── orchestrator_readme.md
├── scripts/
│   ├── entrypoint.sh                  # Main entrypoint (reads ENV_PROFILE, branches by mode)
│   ├── survey_environment.sh          # Detects environment, generates ENV_PROFILE.json
│   ├── bootstrap_minimal_loop.sh      # Minimal infrastructure verification
│   ├── run_dev_task.sh                # Dev task runner
│   ├── run_qa_task.sh                 # QA task runner
│   └── run_task_pipeline.sh           # Pipeline orchestrator
├── runtime/
│   ├── jobs/                          # Task JSON files (PM → dev/qa handoff)
│   ├── artifacts/                     # Dev results and QA results
│   │   ├── <task_id>_dev_result.json  # Dev output
│   │   └── <task_id>_qa_result.json   # QA output
│   ├── status/                        # Runtime status
│   │   ├── system_ready.json          # Ready signal
│   │   └── task_result.json           # Latest task result pointer
│   ├── schemas/                       # JSON schemas
│   │   └── task_result.schema.json    # task_result validation schema
│   └── scripts/                       # Runtime scripts
│       └── validate_task_result.sh    # Schema validation script
└── tests/                             # Project tests
```

## Skill → Script Mapping

| Skill | Script |
|-------|--------|
| `skills/dev` | `scripts/run_dev_task.sh` |
| `skills/qa` | `scripts/run_qa_task.sh` |
| `skills/project-bootstrap` | `scripts/bootstrap_minimal_loop.sh` |

## Bootstrap Modes

| Mode | Behavior |
|------|----------|
| `qwen` | Automatic initialization via Qwen CLI |
| `manual` | Print manual operation guide, no auto-execution |
| `openclaw_minimal` | Wait for PM (OpenClaw) scheduling |

## Quick Start

```bash
# Create new instance
bash create_project.sh /path/to/new/project

# Or create without auto-bootstrap
bash create_project.sh /path/to/new/project --no-bootstrap

# Manual bootstrap
cd /path/to/new/project
bash scripts/survey_environment.sh
bash scripts/entrypoint.sh
```

## Result File Conventions

| File | Purpose |
|------|---------|
| `runtime/status/task_result.json` | Latest task result (pointer/index, overwritten per task) |
| `runtime/artifacts/<task_id>_dev_result.json` | Dev output for specific task |
| `runtime/artifacts/<task_id>_qa_result.json` | QA verification result for specific task |

## Template Version

See `config/template_version.json` for current version and compatibility.