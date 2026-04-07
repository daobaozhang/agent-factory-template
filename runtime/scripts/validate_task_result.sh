#!/bin/bash

# Minimal task_result.json validator
# Validates task_result.json against task_result.schema.json

SCHEMA="/volume2/ai/ppt_agent_factory/runtime/schemas/task_result.schema.json"
TASK_RESULT="/volume2/ai/ppt_agent_factory/runtime/status/task_result.json"

if [ ! -f "$SCHEMA" ]; then
  echo "ERROR: Schema file not found: $SCHEMA"
  exit 1
fi

if [ ! -f "$TASK_RESULT" ]; then
  echo "ERROR: Task result file not found: $TASK_RESULT"
  exit 1
fi

python3 - "$SCHEMA" "$TASK_RESULT" <<'PY'
import json
import sys

schema_path = sys.argv[1]
result_path = sys.argv[2]

# 1. Parse schema
try:
    with open(schema_path, "r") as f:
        schema = json.load(f)
except json.JSONDecodeError as e:
    print(f"FAIL: Schema is not valid JSON: {e}")
    sys.exit(1)

# 2. Parse task_result
try:
    with open(result_path, "r") as f:
        result = json.load(f)
except json.JSONDecodeError as e:
    print(f"FAIL: Task result is not valid JSON: {e}")
    sys.exit(1)

# 3. Read required array
required = schema.get("required", [])
if not required:
    print("FAIL: Schema has no 'required' array")
    sys.exit(1)

# 4. Check all required fields exist
for field in required:
    if field not in result:
        print(f"FAIL: Missing required field: {field}")
        sys.exit(1)

# 5. Check status is success or fail
status = result.get("status")
if status not in ("success", "fail"):
    print(f"FAIL: status must be 'success' or 'fail', got: {status}")
    sys.exit(1)

print("PASS: All checks passed")
sys.exit(0)
PY

exit $?
