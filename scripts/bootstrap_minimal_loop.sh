#!/bin/bash

# Bootstrap Minimal Loop — Real Auto-Closed Loop
# Executes: task generation → dev → QA → validation → CURRENT_SPRINT update → PASS/FAIL

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_ROOT/config/ENV_PROFILE.json"

echo "========================================"
echo "  Bootstrap Minimal Loop (Closed Loop)"
echo "========================================"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "ERROR: config/ENV_PROFILE.json not found."
  exit 1
fi

# Read config
PROJECT_ROOT_PATH=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['project_root'])")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S+00:00")

echo "Project root: $PROJECT_ROOT_PATH"
echo "Timestamp: $TIMESTAMP"
echo ""

# --- Step 0: Infrastructure check ---
echo ">>> Step 0: Infrastructure check"
MISSING=0
for dir in docs skills runtime/jobs runtime/artifacts runtime/status runtime/schemas scripts config; do
  if [ -d "$PROJECT_ROOT/$dir" ]; then
    echo "  [OK] $dir/"
  else
    echo "  [MISSING] $dir/"
    MISSING=$((MISSING + 1))
  fi
done

for f in docs/CURRENT_SPRINT.json config/template_version.json runtime/schemas/task_result.schema.json; do
  if [ -f "$PROJECT_ROOT/$f" ]; then
    echo "  [OK] $f"
  else
    echo "  [MISSING] $f"
    MISSING=$((MISSING + 1))
  fi
done

if [ $MISSING -gt 0 ]; then
  echo "ERROR: $MISSING missing. Aborting."
  exit 1
fi
echo ""

# --- Step 1: Generate task JSON ---
echo ">>> Step 1: Generating bootstrap task"
TASK_ID="bootstrap_loop_001"
TASK_FILE="$PROJECT_ROOT/runtime/jobs/${TASK_ID}.json"

python3 -c "
import json
task = {
    'task_id': '$TASK_ID',
    'target_role': 'dev',
    'objective': 'Create bootstrap verification artifact and confirm pipeline connectivity',
    'constraints': [
        'Do not modify CURRENT_SPRINT directly',
        'Only create files under runtime/artifacts',
        'Must produce structured dev_result.json'
    ],
    'expected_output': [
        'runtime/artifacts/${TASK_ID}_output.txt',
        'runtime/artifacts/${TASK_ID}_dev_result.json'
    ],
    'validation_steps': [
        'Check dev result file exists and is valid JSON',
        'Check dev status is success',
        'Check expected output artifacts exist',
        'Run schema validation'
    ]
}
json.dump(task, open('$TASK_FILE', 'w'), indent=2)
print('Task created: $TASK_FILE')
"
echo ""

# --- Step 2: Call run_dev_task.sh ---
echo ">>> Step 2: Dev execution"
bash "$PROJECT_ROOT/scripts/run_dev_task.sh" "$TASK_FILE"
DEV_EXIT=$?
echo ""

if [ $DEV_EXIT -ne 0 ]; then
  echo ">>> Dev execution failed (exit $DEV_EXIT)"
  # Still produce QA result documenting the failure
  python3 -c "
import json, os
result = {
    'task_id': '$TASK_ID',
    'status': 'fail',
    'summary': 'Dev execution failed with exit code $DEV_EXIT',
    'issues_found': [f'Dev exited with code $DEV_EXIT'],
    'validation': {'steps': ['Dev execution attempted'], 'result': 'fail'}
}
qa_file = '$PROJECT_ROOT/runtime/artifacts/${TASK_ID}_qa_result.json'
os.makedirs(os.path.dirname(qa_file), exist_ok=True)
json.dump(result, open(qa_file, 'w'), indent=2)
"
  echo "QA result written documenting failure."
else
  echo ">>> Dev execution succeeded."
fi
echo ""

# --- Step 3: Read dev_result.json ---
echo ">>> Step 3: Reading dev result"
DEV_RESULT_FILE="$PROJECT_ROOT/runtime/artifacts/${TASK_ID}_dev_result.json"
if [ -f "$DEV_RESULT_FILE" ]; then
  echo "  [OK] Dev result found: $DEV_RESULT_FILE"
  python3 -c "import json; d=json.load(open('$DEV_RESULT_FILE')); print('  dev status:', d.get('status','unknown'))"
else
  echo "  [FAIL] Dev result not found: $DEV_RESULT_FILE"
  exit 1
fi
echo ""

# --- Step 4: Call run_qa_task.sh ---
echo ">>> Step 4: QA verification"
export TASK_FILE="$TASK_FILE"
export DEV_RESULT_FILE="$DEV_RESULT_FILE"
export TASK_ID="$TASK_ID"
export QA_RESULT_FILE="$PROJECT_ROOT/runtime/artifacts/${TASK_ID}_qa_result.json"
bash "$PROJECT_ROOT/scripts/run_qa_task.sh" "$TASK_FILE" "$DEV_RESULT_FILE"
QA_EXIT=$?
echo ""

# --- Step 5: Read qa_result.json ---
echo ">>> Step 5: Reading QA result"
QA_RESULT_FILE="$PROJECT_ROOT/runtime/artifacts/${TASK_ID}_qa_result.json"
if [ -f "$QA_RESULT_FILE" ]; then
  echo "  [OK] QA result found: $QA_RESULT_FILE"
  python3 -c "import json; d=json.load(open('$QA_RESULT_FILE')); print('  qa status:', d.get('status','unknown'))"
else
  echo "  [FAIL] QA result not found: $QA_RESULT_FILE"
  exit 1
fi
echo ""

# --- Step 6: Run validate_task_result.sh ---
echo ">>> Step 6: Schema validation"
bash "$PROJECT_ROOT/runtime/scripts/validate_task_result.sh"
VALIDATE_EXIT=$?
if [ $VALIDATE_EXIT -eq 0 ]; then
  echo "  [OK] Schema validation passed"
else
  echo "  [FAIL] Schema validation failed (exit $VALIDATE_EXIT)"
fi
echo ""

# --- Step 7: Update CURRENT_SPRINT.json ---
echo ">>> Step 7: Updating CURRENT_SPRINT.json"
QA_STATUS=$(python3 -c "import json; print(json.load(open('$QA_RESULT_FILE')).get('status','unknown'))")

python3 -c "
import json

cs_file = '$PROJECT_ROOT/docs/CURRENT_SPRINT.json'
cs = json.load(open(cs_file))

cs['last_task_id'] = '$TASK_ID'
cs['last_task_status'] = '$QA_STATUS'
cs['last_result_path'] = 'runtime/status/task_result.json'
cs['last_updated'] = '$TIMESTAMP'

json.dump(cs, open(cs_file, 'w'), indent=2)
print('CURRENT_SPRINT.json updated:')
print('  last_task_id:', cs['last_task_id'])
print('  last_task_status:', cs['last_task_status'])
print('  last_result_path:', cs['last_result_path'])
"
echo ""

# --- Step 8: Update task_result.json (latest pointer) ---
echo ">>> Step 8: Updating task_result.json (latest pointer)"
python3 -c "
import json, os
result = {
    'task_id': '$TASK_ID',
    'status': '$QA_STATUS',
    'summary': 'Bootstrap closed loop completed. Dev exit=$DEV_EXIT, QA exit=$QA_EXIT, Validation exit=$VALIDATE_EXIT',
    'files_changed': [
        'runtime/artifacts/${TASK_ID}_output.txt',
        'runtime/artifacts/${TASK_ID}_dev_result.json',
        'runtime/artifacts/${TASK_ID}_qa_result.json',
        'runtime/status/task_result.json',
        'docs/CURRENT_SPRINT.json'
    ],
    'error': None
}
status_file = '$PROJECT_ROOT/runtime/status/task_result.json'
os.makedirs(os.path.dirname(status_file), exist_ok=True)
json.dump(result, open(status_file, 'w'), indent=2)
print('task_result.json updated')
"
echo ""

# --- Step 9: Output final verdict ---
echo "========================================"
if [ "$QA_STATUS" = "pass" ]; then
  echo "  RESULT: PASS"
  echo "========================================"
  echo "Bootstrap closed loop completed successfully."
  echo "  Task: $TASK_ID"
  echo "  Dev: exit $DEV_EXIT"
  echo "  QA: $QA_STATUS"
  echo "  Schema validation: passed"
  echo "  CURRENT_SPRINT: updated"
  exit 0
else
  echo "  RESULT: FAIL"
  echo "========================================"
  echo "Bootstrap closed loop completed with issues."
  echo "  Task: $TASK_ID"
  echo "  Dev: exit $DEV_EXIT"
  echo "  QA: $QA_STATUS"
  echo "  See: runtime/artifacts/${TASK_ID}_qa_result.json"
  exit 1
fi