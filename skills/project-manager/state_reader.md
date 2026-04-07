# State Reader

## Purpose
The project-manager must read structured state before making any decision.

## Sources of Truth

### 1. CURRENT_SPRINT.json
Path:
docs/CURRENT_SPRINT.json

Contains:
- current phase
- current task
- blockers
- next actions

This is the machine-readable source of truth.

### 2. CURRENT_SPRINT.md
Path:
docs/CURRENT_SPRINT.md

Human-readable version of sprint state.

### 3. Task Results
Path:
runtime/jobs/*.json

Each file represents a completed task result.

## Reading Rules

1. Always read CURRENT_SPRINT.json first
2. Use CURRENT_SPRINT.md only for human context
3. Aggregate task_result.json files when needed
4. Never assume state from chat history
5. Always rely on file-based state

## Constraints

- Do not modify state during read phase
- Do not trigger execution
- This step is read-only

## Future Extension

This module will later be mapped to actual file-reading tools in OpenClaw.