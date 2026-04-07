# Task Closure Protocol

## Purpose
Define how project-manager closes a task when qa returns PASS.

## Trigger

This protocol is triggered when:

- qa task_result.json exists
- qa status is pass

## PM Responsibilities

When qa returns PASS, PM must:

1. Read qa task_result.json
2. Confirm the original task objective was completed
3. Confirm expected_output was produced
4. Confirm no constraint violation is recorded
5. Mark the task as closed in PM decision flow
6. Prepare the next smallest valid task

## Closure Rules

A task may be closed only if:

- qa status is pass
- task_result.json is present
- expected_output exists
- no open failure remains for the same task
- closure is based on evidence, not assumption

## Constraints

PM must not:

- close a task before qa PASS
- skip evidence review
- merge unfinished work into closure
- treat partial completion as full completion
- modify dev or qa result files

## Evidence Rules

PM must base closure on:

- original task definition
- dev task_result.json
- qa task_result.json
- visible task artifacts

PM must not infer completion without evidence.

## Closure Sequence

1. QA returns PASS
2. PM reviews evidence
3. PM confirms closure conditions
4. PM closes the task in decision flow
5. PM prepares the next smallest task

## Rules

1. Always close tasks explicitly
2. Always preserve traceability
3. Never close based on assumption
4. Never skip qa evidence
5. Keep task progression step by step

## Current Stage Behavior

At the current stage:

- human still triggers execution
- PM explicitly decides task closure
- dev and qa remain separate roles
- task_result.json remains mandatory

## Future Goal

This protocol will later support OpenClaw-managed task completion and progression decisions.