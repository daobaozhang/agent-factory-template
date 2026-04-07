# TASK RESULT SCHEMA

## Purpose
Each worker task must output a structured `task_result.json` file.
This file is the required delivery artifact for project-manager aggregation.

A task is not considered completed unless a valid task_result.json is produced.

## Required Fields

### task_id
Unique task identifier.

### executor
Actual executor name, such as `qwen`, `codex`, or `opencode`.

### role
Execution role, such as `bootstrap_worker`, `developer_worker`, or `patch_worker`.

### branch
Git branch used for the task.  
If Git is not involved yet, use `N/A`.

### changed_files
Array of changed file paths.

### tests_run
Array of executed test or validation commands.

### test_results
Array of human-readable results corresponding to `tests_run`.

### risks
Array of current known risks or unresolved concerns.

### summary
Short summary of what was completed.

### status
Must be one of:
- success
- partial
- failed

### timestamp
Execution completion time in ISO-like string format.

## Minimal JSON Example

```json
{
  "task_id": "phase1_task1_step5",
  "executor": "qwen",
  "role": "bootstrap_worker",
  "branch": "N/A",
  "changed_files": [
    "docs/TASK_RESULT_SCHEMA.md"
  ],
  "tests_run": [
    "ls -l /volume2/ai/ppt_agent_factory/docs"
  ],
  "test_results": [
    "TASK_RESULT_SCHEMA.md created successfully"
  ],
  "risks": [],
  "summary": "Created the task result schema definition for worker delivery.",
  "status": "success",
  "timestamp": "2026-04-07T12:50:00"
}
