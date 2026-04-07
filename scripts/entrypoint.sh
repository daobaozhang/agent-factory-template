#!/bin/bash

# Agent Factory Entrypoint
# Reads config/ENV_PROFILE.json and branches based on bootstrap.mode

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_ROOT/config/ENV_PROFILE.json"
BOOTSTRAP_SCRIPT="$PROJECT_ROOT/scripts/bootstrap_minimal_loop.sh"

# --- Pre-flight checks ---

if [ ! -f "$CONFIG_FILE" ]; then
  echo "ERROR: config/ENV_PROFILE.json not found."
  echo "Run create_project.sh or copy config/ENV_PROFILE.template.json to config/ENV_PROFILE.json first."
  exit 1
fi

# --- Read bootstrap.mode from ENV_PROFILE.json ---

BOOTSTRAP_MODE=$(python3 -c "
import json, sys
try:
    with open('$CONFIG_FILE') as f:
        cfg = json.load(f)
    print(cfg.get('bootstrap.mode', 'unknown'))
except Exception as e:
    print(f'ERROR: Failed to parse config: {e}', file=sys.stderr)
    sys.exit(1)
" 2>&1)

if [ $? -ne 0 ]; then
  echo "ERROR: Cannot read bootstrap.mode from config."
  echo "$BOOTSTRAP_MODE"
  exit 1
fi

echo "=== Agent Factory Entrypoint ==="
echo "Config: $CONFIG_FILE"
echo "Mode: $BOOTSTRAP_MODE"
echo ""

# --- Branch on bootstrap.mode ---

case "$BOOTSTRAP_MODE" in
  qwen)
    echo ">>> Entering automatic Qwen bootstrap flow."
    echo ">>> This will initialize the minimal execution loop."
    if [ -x "$BOOTSTRAP_SCRIPT" ]; then
      echo ">>> Calling $BOOTSTRAP_SCRIPT"
      bash "$BOOTSTRAP_SCRIPT"
      RC=$?
      if [ $RC -eq 0 ]; then
        echo ">>> Bootstrap minimal loop completed successfully."
      else
        echo ">>> Bootstrap minimal loop exited with code $RC."
      fi
      exit $RC
    else
      echo ">>> [PLACEHOLDER] bootstrap_minimal_loop.sh not found or not executable."
      echo ">>> In a full implementation, this would initialize Qwen CLI task execution."
      exit 0
    fi
    ;;

  manual)
    echo ">>> Manual mode selected."
    echo ">>> Automatic bootstrap is disabled."
    echo ""
    echo "Manual operation guide:"
    echo "  1. PM creates task JSON in runtime/jobs/"
    echo "  2. Run: bash scripts/run_dev_task.sh runtime/jobs/<task_file>"
    echo "  3. Run: bash scripts/run_qa_task.sh runtime/jobs/<task_file> runtime/artifacts/<task_id>_result.json"
    echo "  4. PM reviews QA result and decides next step."
    echo ""
    echo ">>> No automatic action taken. Exiting with code 0."
    exit 0
    ;;

  openclaw_minimal)
    echo ">>> OpenClaw minimal mode selected."
    echo ">>> Waiting for PM (project-manager) to schedule tasks."
    echo ""
    echo ">>> This mode expects OpenClaw to:"
    echo "  1. Read CURRENT_SPRINT.json for sprint state"
    echo "  2. Select and delegate tasks via skill definitions"
    echo "  3. Monitor runtime/status/task_result.json for completion"
    echo ""
    echo ">>> If OpenClaw is not connected, no action will be taken."
    echo ">>> Exiting with code 0."
    exit 0
    ;;

  *)
    echo "ERROR: Unknown bootstrap.mode: '$BOOTSTRAP_MODE'"
    echo "Valid modes: qwen, manual, openclaw_minimal"
    echo "Fix: Update config/ENV_PROFILE.json with a valid bootstrap.mode value."
    exit 1
    ;;
esac