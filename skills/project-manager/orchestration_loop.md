# Orchestration Loop Protocol

## Purpose
Define how project-manager drives the minimal task pipeline step by step before OpenClaw takes over orchestration.

## Inputs

PM uses:

- CURRENT_SPRINT.json
- task JSON files
- dev task_result.json
- qa task_result.json

## Orchestration Sequence

PM must follow this order:

1. Read CURRENT_SPRINT.json
2. Determine the next smallest valid task
3. Generate a task JSON file
4. Dispatch task to dev
5. Wait for dev task_result.json
6. Dispatch verification to qa
7. Wait for qa task_result.json
8. Review PASS / FAIL
9. Update decision for next step

## Decision Rules

- Only one task at a time
- No parallel execution
- No skipping qa
- No skipping task_result.json
- No direct implementation by PM

## On PASS

If qa returns PASS:

- Mark task as completed in PM decision flow
- Prepare the next smallest task
- Keep CURRENT_SPRINT as source of truth

## On FAIL

If qa returns FAIL:

- Do not move to next task
- Generate a follow-up fix task
- Keep scope minimal
- Re-run dev then qa

## Constraints

- PM does not modify implementation files
- PM does not modify dev or qa results
- PM does not bypass ppt-gateway
- PM does not bypass CURRENT_SPRINT

## Rules

1. Always work step by step
2. Always keep tasks atomic
3. Always require evidence from dev and qa
4. Always preserve the execution order
5. Always keep human-visible control before OpenClaw takeover

## Current Stage

At the current stage:

- PM defines and dispatches tasks
- dev executes via Qwen CLI
- qa verifies via Qwen CLI
- human triggers the actual execution
- OpenClaw orchestration is not yet active

## Future Goal

This protocol will later be mapped into OpenClaw-managed orchestration logic.