# Bootstrap Flow Protocol

## Purpose
Define how a new Agent Factory instance is initialized from the template.

## Bootstrap Sequence

1. **Template Copy**
   - `create_project.sh` copies template to target directory
   - Supports `--no-bootstrap` for manual initialization only

2. **Version Check**
   - Read `config/template_version.json`
   - Verify template version and phase baseline compatibility

3. **Environment Survey**
   - Run `scripts/survey_environment.sh`
   - Detect: environment type, executor, gateway port, OpenClaw container
   - Generate `config/ENV_PROFILE.json` from template

4. **Entrypoint Execution**
   - Run `scripts/entrypoint.sh`
   - Read `config/ENV_PROFILE.json`
   - Branch on `bootstrap.mode`:
     - `qwen`: Call `scripts/bootstrap_minimal_loop.sh`
     - `manual`: Print manual operation guide
     - `openclaw_minimal`: Wait for PM scheduling

5. **Infrastructure Verification**
   - `scripts/bootstrap_minimal_loop.sh` checks all required directories and files
   - Reports missing components

6. **Ready State**
   - System signals readiness for PM task orchestration
   - `runtime/status/system_ready.json` may be generated

## Skill-to-Script Mapping

| Skill | Script |
|-------|--------|
| `skills/dev` | `scripts/run_dev_task.sh` |
| `skills/qa` | `scripts/run_qa_task.sh` |
| `skills/project-bootstrap` | `scripts/bootstrap_minimal_loop.sh` |

## Constraints

- Does not modify Phase 3 core decision protocols
- Does not implement business logic
- Does not hardcode paths, ports, or container names
- Template files (`*.template.json`) are never modified — only instantiated copies