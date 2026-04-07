#!/bin/bash

# Init Current Sprint Script
# Creates initial sprint state files and readiness signals.
# Usage: bash init_current_sprint.sh [PROJECT_ROOT]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="${1:-$(dirname "$SCRIPT_DIR")}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S+00:00")

echo "=== Init Current Sprint ==="
echo "Project root: $PROJECT_ROOT"

# --- Create CURRENT_SPRINT.json ---

mkdir -p "$PROJECT_ROOT/docs"

cat > "$PROJECT_ROOT/docs/CURRENT_SPRINT.json" <<EOF
{
  "phase": "phase_0_bootstrap",
  "sprint_goal": "Initialize project and verify minimal task loop",
  "current_task": "bootstrap_environment_check",
  "task_status": "pending",
  "constraints": [
    "OpenClaw cannot write code",
    "Worker cannot modify CURRENT_SPRINT",
    "ppt-gateway is the only entry point"
  ],
  "blockers": [],
  "next_actions": [
    "Verify infrastructure completeness",
    "Run minimal task loop test",
    "Bootstrap first skill/script mapping"
  ],
  "last_updated": "$TIMESTAMP",
  "last_task_id": "",
  "last_task_status": "",
  "last_result_path": "",
  "template_status": "initialized"
}
EOF

echo "  [OK] docs/CURRENT_SPRINT.json created"

# --- Create CURRENT_SPRINT.md ---

cat > "$PROJECT_ROOT/docs/CURRENT_SPRINT.md" <<EOF
# CURRENT SPRINT

## Phase
phase_0_bootstrap

## Goal
Initialize project and verify minimal task loop

## Current Task
bootstrap_environment_check

## Status
Pending

## Constraints
- OpenClaw cannot write code
- Worker cannot modify CURRENT_SPRINT
- ppt-gateway is the only entry point

## Blockers
None

## Next
- Verify infrastructure completeness
- Run minimal task loop test
- Bootstrap first skill/script mapping
EOF

echo "  [OK] docs/CURRENT_SPRINT.md created"

# --- Create runtime/status/ ---

mkdir -p "$PROJECT_ROOT/runtime/status"
mkdir -p "$PROJECT_ROOT/runtime/artifacts"

cat > "$PROJECT_ROOT/runtime/status/system_ready.json" <<EOF
{
  "phase": "phase_0_bootstrap",
  "status": "ready",
  "timestamp": "$TIMESTAMP",
  "message": "Project initialized, ready for PM orchestration"
}
EOF

echo "  [OK] runtime/status/system_ready.json created"

cat > "$PROJECT_ROOT/runtime/status/task_result.json" <<EOF
{
  "task_id": "bootstrap_init_sprint",
  "status": "success",
  "summary": "Initial sprint state files and readiness signals created",
  "files_changed": [
    "docs/CURRENT_SPRINT.json",
    "docs/CURRENT_SPRINT.md",
    "runtime/status/system_ready.json",
    "runtime/status/task_result.json"
  ],
  "error": null
}
EOF

echo "  [OK] runtime/status/task_result.json created"

echo "=== Init Current Sprint Complete ==="