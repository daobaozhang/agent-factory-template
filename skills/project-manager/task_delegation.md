# Task Delegation Protocol

## Purpose
Define how the project-manager delegates work to dev and qa roles.

## Delegation Targets

### dev
Responsible for implementation tasks.

### qa
Responsible for verification tasks.

## Task Structure

Each delegated task must include:

- task_id
- target_role (dev or qa)
- objective
- constraints
- expected_output
- validation_steps

## Example (dev task)

task_id: phaseX_taskY_stepZ

target_role: dev

objective:
Implement a minimal API endpoint.

constraints:
- Do not modify CURRENT_SPRINT
- Only change allowed files
- Must produce task_result.json

expected_output:
- Updated code files
- task_result.json

validation_steps:
- curl endpoint
- verify response

## Example (qa task)

task_id: phaseX_taskY_validation

target_role: qa

objective:
Verify API correctness and constraints.

constraints:
- Do not modify code
- Only validate behavior

expected_output:
- verification result
- task_result.json

validation_steps:
- call API
- check response
- confirm constraints

## Rules

1. Always assign a clear target_role
2. Always define validation_steps
3. Always require task_result.json
4. Never delegate vague tasks
5. Keep tasks small and atomic

## Current Stage Behavior

- Only delegate minimal steps
- Avoid multi-step tasks
- Avoid parallel execution
- Keep full control over sequence

## Future Extension

This protocol will later be used to generate actual execution prompts for workers.