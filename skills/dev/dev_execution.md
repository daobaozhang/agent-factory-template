# Dev Execution Protocol

## Purpose
Define how dev receives tasks from project-manager and executes them via Qwen CLI.

## Input

dev receives a task with the following structure:

- task_id
- target_role
- objective
- constraints
- expected_output
- validation_steps

## Execution Flow

1. Read task
2. Understand objective and constraints
3. Translate task into Qwen CLI prompt
4. Execute via Qwen CLI
5. Generate task_result.json

## Qwen CLI Translation Rules

When converting a task into a Qwen CLI prompt:

- Always restate objective clearly
- Always include constraints
- Always specify file paths
- Never skip expected_output
- Never skip validation_steps

## Output Requirements

dev must always produce:

- Updated files (if any)
- task_result.json

### task_result.json Structure

```json
{
  "task_id": "",
  "status": "success | fail",
  "files_modified": [],
  "summary": "",
  "validation": {
    "steps": [],
    "result": ""
  }
}
```

## Constraints

- Do not modify CURRENT_SPRINT
- Only modify allowed files
- Follow task strictly
- Do not self-extend task scope

## Failure Handling

If execution fails:

- Record error in task_result.json
- Do not retry blindly
- Do not change task definition

## Rules

- Always follow PM task exactly
- Never invent extra steps
- Always produce task_result.json
- Keep execution minimal and controlled