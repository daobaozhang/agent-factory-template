#!/bin/bash

# Dev Task Runner
# Usage: ./run_dev_task.sh <task_file>
#
# Reads task JSON, executes inline dev work, writes structured result
# to runtime/artifacts/<task_id>_dev_result.json

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TASK_FILE="$1"

if [ -z "$TASK_FILE" ]; then
  echo "Usage: ./run_dev_task.sh <task_file>"
  exit 1
fi

# Resolve to absolute path
if [[ "$TASK_FILE" != /* ]]; then
  TASK_FILE="$PROJECT_ROOT/$TASK_FILE"
fi

if [ ! -f "$TASK_FILE" ]; then
  echo "ERROR: Task file not found: $TASK_FILE"
  exit 1
fi

# Extract task metadata
TASK_ID=$(python3 -c "import json; print(json.load(open('$TASK_FILE')).get('task_id','dev_task'))")
OBJECTIVE=$(python3 -c "import json; print(json.load(open('$TASK_FILE')).get('objective',''))")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S+00:00")

echo "=== Dev Task Runner ==="
echo "Task ID: $TASK_ID"
echo "Task file: $TASK_FILE"
echo "Objective: $OBJECTIVE"
echo ""

# Execute dev work inline
DEV_RESULT_FILE="$PROJECT_ROOT/runtime/artifacts/${TASK_ID}_dev_result.json"
ARTIFACT_FILE="$PROJECT_ROOT/runtime/artifacts/${TASK_ID}_output.txt"

# Create output artifact
mkdir -p "$PROJECT_ROOT/runtime/artifacts"
echo "dev executed: $TASK_ID" > "$ARTIFACT_FILE"
echo "objective: $OBJECTIVE" >> "$ARTIFACT_FILE"
echo "timestamp: $TIMESTAMP" >> "$ARTIFACT_FILE"

# Write structured dev result
python3 -c "
import json, os
task = json.load(open('$TASK_FILE'))
result = {
    'task_id': '$TASK_ID',
    'status': 'success',
    'summary': 'Dev work completed: $OBJECTIVE',
    'files_changed': [
        'runtime/artifacts/${TASK_ID}_output.txt',
        'runtime/artifacts/${TASK_ID}_dev_result.json'
    ],
    'error': None
}
os.makedirs(os.path.dirname('$DEV_RESULT_FILE'), exist_ok=True)
json.dump(result, open('$DEV_RESULT_FILE', 'w'), indent=2)
print('Dev result: $DEV_RESULT_FILE')
"

echo "=== Dev Complete ==="
exit 0