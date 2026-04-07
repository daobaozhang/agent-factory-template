#!/bin/bash

# Task Pipeline Runner
# Usage: ./run_task_pipeline.sh runtime/jobs/task_001.json runtime/artifacts/task_001_result.json

TASK_FILE=$1
DEV_RESULT_FILE=$2
PROJECT_ROOT="/volume2/ai/ppt_agent_factory"
DEV_RUNNER="$PROJECT_ROOT/scripts/run_dev_task.sh"
QA_RUNNER="$PROJECT_ROOT/scripts/run_qa_task.sh"

if [ -z "$TASK_FILE" ] || [ -z "$DEV_RESULT_FILE" ]; then
  echo "Usage: ./run_task_pipeline.sh <task_file> <dev_result_file>"
  exit 1
fi

echo "=== Task Pipeline Start ==="

echo "=== Step 1: Dev Execution ==="
echo "$DEV_RUNNER $TASK_FILE"

echo "=== Step 2: QA Verification ==="
echo "$QA_RUNNER $TASK_FILE $DEV_RESULT_FILE"

echo "=== Task Pipeline Ready ==="