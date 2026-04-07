# Pipeline Overview

## Purpose
Describe the current minimal task pipeline before OpenClaw takes over orchestration.

## Current Pipeline

Current execution flow:

PM
→ task JSON
→ run_dev_task.sh
→ dev output (artifacts + task_result.json)
→ run_qa_task.sh
→ qa output (PASS / FAIL + task_result.json)

## Components

### project-manager
Responsible for:
- reading state
- making decisions
- delegating tasks
- generating execution prompts

### dev
Responsible for:
- receiving task input
- executing implementation via Qwen CLI
- producing task_result.json

### qa
Responsible for:
- verifying dev output
- producing PASS / FAIL
- producing task_result.json

### scripts
Current execution entrypoints:
- scripts/run_dev_task.sh
- scripts/run_qa_task.sh
- scripts/run_task_pipeline.sh

## Current Constraints

- Human still triggers each step
- OpenClaw has not taken over orchestration
- CURRENT_SPRINT remains the source of truth
- ppt-gateway remains within system boundary
- task_result.json is mandatory

## Current System Status

The system already has:

- task delegation protocol
- dev execution protocol
- qa verification protocol
- prompt generation protocol
- minimal dev/qa runners
- minimal task pipeline entry

## Next Stage

Next stage goal:

Enable OpenClaw to orchestrate the pipeline automatically based on PM decisions and task files.

## Rules

1. Do not bypass task JSON
2. Do not bypass task_result.json
3. Do not bypass qa verification
4. Do not allow dev to change sprint state
5. Keep tasks small and sequential