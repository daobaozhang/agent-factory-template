# QA Verification Protocol

## Purpose
Define how qa verifies dev task results and produces a PASS / FAIL conclusion.

## Input

qa receives:

- original task
- dev task_result.json
- changed files (if any)
- validation evidence

## Verification Scope

qa must verify:

- objective was completed
- constraints were respected
- expected_output was produced
- validation_steps were actually executed
- task_result.json is present and valid

## Verification Flow

1. Read original task
2. Read dev task_result.json
3. Inspect changed files
4. Execute or review validation steps
5. Produce PASS / FAIL
6. Generate task_result.json

## PASS Criteria

PASS only if all of the following are true:

- Objective completed
- No constraint violation
- Expected output exists
- Validation evidence is sufficient
- task_result.json is complete

## FAIL Criteria

FAIL if any of the following happens:

- Objective incomplete
- Constraints violated
- Missing expected output
- Validation not executed
- task_result.json missing or invalid

## Output Requirements

qa must always produce:

1. verification conclusion
2. task_result.json

### task_result.json Structure

```json
{
  "task_id": "",
  "status": "pass | fail",
  "summary": "",
  "issues_found": [],
  "validation": {
    "steps": [],
    "result": ""
  }
}
```

## Constraints

- Do not modify implementation files
- Do not change task scope
- Only verify based on task definition and evidence
- Do not guess success without proof

## Rules

1. Default to skepticism
2. PASS only with evidence
3. FAIL if proof is insufficient
4. Always produce task_result.json
5. Keep verification strict and minimal