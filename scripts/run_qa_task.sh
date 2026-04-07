#!/bin/bash

# QA Task Runner
# Usage: ./run_qa_task.sh <task_file> <dev_result_file>
#
# Reads task JSON + dev result, performs inline verification,
# writes structured result to runtime/artifacts/<task_id>_qa_result.json

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TASK_FILE="$1"
DEV_RESULT_FILE="$2"

if [ -z "$TASK_FILE" ] || [ -z "$DEV_RESULT_FILE" ]; then
  echo "Usage: ./run_qa_task.sh <task_file> <dev_result_file>"
  exit 1
fi

# Resolve to absolute paths
if [[ "$TASK_FILE" != /* ]]; then
  TASK_FILE="$PROJECT_ROOT/$TASK_FILE"
fi
if [[ "$DEV_RESULT_FILE" != /* ]]; then
  DEV_RESULT_FILE="$PROJECT_ROOT/$DEV_RESULT_FILE"
fi

if [ ! -f "$TASK_FILE" ]; then
  echo "ERROR: Task file not found: $TASK_FILE"
  exit 1
fi
if [ ! -f "$DEV_RESULT_FILE" ]; then
  echo "ERROR: Dev result file not found: $DEV_RESULT_FILE"
  exit 1
fi

TASK_ID=$(python3 -c "import json; print(json.load(open('$TASK_FILE')).get('task_id','dev_task'))")
QA_RESULT_FILE="$PROJECT_ROOT/runtime/artifacts/${TASK_ID}_qa_result.json"

echo "=== QA Task Runner ==="
echo "Task ID: $TASK_ID"
echo "Task file: $TASK_FILE"
echo "Dev result: $DEV_RESULT_FILE"
echo ""

# Perform inline QA verification
export TASK_FILE="$TASK_FILE"
export DEV_RESULT_FILE="$DEV_RESULT_FILE"
export TASK_ID="$TASK_ID"
export QA_RESULT_FILE="$QA_RESULT_FILE"

python3 << 'PYEOF'
import json, os

task_file = os.environ["TASK_FILE"]
dev_result_file = os.environ["DEV_RESULT_FILE"]
task_id = os.environ["TASK_ID"]
qa_result_file = os.environ["QA_RESULT_FILE"]

issues = []
steps_passed = []

# 1. Validate dev result is valid JSON
try:
    dev_result = json.load(open(dev_result_file))
    steps_passed.append("dev_result.json is valid JSON")
except Exception as e:
    issues.append(f"dev_result.json invalid: {e}")
    dev_result = None

# 2. Check dev result has required fields
if dev_result:
    for field in ["task_id", "status", "summary"]:
        if field in dev_result:
            steps_passed.append(f"dev_result has '{field}'")
        else:
            issues.append(f"dev_result missing '{field}'")

    # 3. Check dev status is success
    if dev_result.get("status") == "success":
        steps_passed.append("dev status is success")
    else:
        issues.append(f"dev status is '{dev_result.get('status')}', expected 'success'")

    # 4. Check files_changed exist
    for f in dev_result.get("files_changed", []):
        if os.path.exists(f):
            steps_passed.append(f"file exists: {f}")
        else:
            issues.append(f"file missing: {f}")

# Determine overall result
if issues:
    qa_status = "fail"
    qa_summary = f"QA failed with {len(issues)} issue(s)"
else:
    qa_status = "pass"
    qa_summary = "All checks passed"

result = {
    "task_id": task_id,
    "status": qa_status,
    "summary": qa_summary,
    "issues_found": issues,
    "validation": {
        "steps": steps_passed,
        "result": qa_status
    }
}

os.makedirs(os.path.dirname(qa_result_file), exist_ok=True)
json.dump(result, open(qa_result_file, "w"), indent=2)
print(f"QA result: {qa_status}")
print(f"QA result written: {qa_result_file}")

import sys
sys.exit(0 if qa_status == "pass" else 1)
PYEOF

QA_EXIT=$?
echo "=== QA Complete (exit $QA_EXIT) ==="
exit $QA_EXIT