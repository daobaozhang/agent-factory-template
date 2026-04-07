# Failure Recovery Protocol

## Purpose
Define how project-manager responds when qa returns FAIL for a delegated task.

## Trigger

This protocol is triggered when:

- qa task_result.json exists
- qa status is fail

## PM Responsibilities

When qa returns FAIL, PM must:

1. Read qa task_result.json
2. Identify the failed objective or violated constraint
3. Determine the smallest possible fix scope
4. Generate a follow-up fix task
5. Re-dispatch the fix task to dev
6. Require qa verification again after dev completes

## Fix Task Rules

A follow-up fix task must:

- keep the original task_id reference
- define only the minimal required fix
- not expand into unrelated work
- preserve the same constraint discipline
- require task_result.json again

## Constraints

PM must not:

- mark the failed task as completed
- skip re-verification
- merge multiple fixes into one vague task
- allow scope expansion
- modify dev or qa result files

## Evidence Rules

PM must base the recovery decision on:

- qa task_result.json
- original task definition
- dev task_result.json
- visible task artifacts

PM must not guess or infer success without evidence.

## Recovery Sequence

1. QA returns FAIL
2. PM reviews evidence
3. PM creates minimal fix task
4. Dev executes fix task
5. QA re-checks fix task
6. PM reviews PASS / FAIL again

## Rules

1. Always keep recovery tasks small
2. Always preserve traceability
3. Always require re-verification
4. Never bypass qa after a fail
5. Never treat fail as partial pass

## Current Stage Behavior

At the current stage:

- human still triggers execution
- PM defines recovery tasks
- dev and qa remain separate roles
- task_result.json remains mandatory

## Future Goal

This protocol will later support OpenClaw-managed retry and fix-task orchestration.