# Task State Transition Protocol

## Purpose
Define how project-manager manages task state transitions across the minimal pipeline.

## Inputs

PM uses:

- CURRENT_SPRINT.json
- CURRENT_SPRINT.md
- task JSON files
- dev task_result.json
- qa task_result.json
- current pipeline state

## Task States

A task may move through the following states:

1. pending
2. delegated_to_dev
3. dev_completed
4. delegated_to_qa
5. qa_passed
6. qa_failed
7. recovery_pending
8. closed

## State Meanings

- pending: task identified but not yet delegated
- delegated_to_dev: task has been issued to dev
- dev_completed: dev produced task_result.json
- delegated_to_qa: task has been issued to qa
- qa_passed: qa verified the task successfully
- qa_failed: qa returned fail
- recovery_pending: PM must create a minimal fix task
- closed: PM has explicitly closed the task after QA PASS

## Transition Rules

PM must only allow the following transitions:

- pending → delegated_to_dev
- delegated_to_dev → dev_completed
- dev_completed → delegated_to_qa
- delegated_to_qa → qa_passed
- delegated_to_qa → qa_failed
- qa_failed → recovery_pending
- recovery_pending → delegated_to_dev
- qa_passed → closed

## PM Must Avoid

PM must not:

- skip intermediate states
- move directly from dev_completed to closed
- close a task before qa_passed
- ignore qa_failed
- merge multiple state changes into one unclear jump

## Transition Sequence

1. Select the next valid pending task
2. Delegate to dev
3. Wait for dev result
4. Delegate to qa
5. Review qa result
6. If pass, close task
7. If fail, move to recovery_pending and create fix task

## Constraints

- CURRENT_SPRINT remains the source of truth
- PM does not invent hidden states
- PM does not bypass qa verification
- PM does not treat partial completion as closed

## Evidence Rules

PM must base every state transition on:

- task JSON
- dev task_result.json
- qa task_result.json
- visible artifacts
- current sprint state

PM must not transition state based on intuition alone.

## Rules

1. Always transition states explicitly
2. Always preserve traceability
3. Always require evidence for state change
4. Always preserve execution order
5. Always keep task progression step by step

## Current Stage Behavior

At the current stage:

- human still triggers execution
- PM explicitly tracks state transitions
- dev and qa remain separate roles
- task JSON remains the handoff format

## Future Goal

This protocol will later support OpenClaw-managed state-aware orchestration.