# Task Tracking Protocol

## Purpose
Define how project-manager records and tracks the core lifecycle information of each task.

## Inputs

PM uses:

- CURRENT_SPRINT.json
- CURRENT_SPRINT.md
- task JSON files
- dev task_result.json
- qa task_result.json
- task state transitions
- current pipeline state

## Tracking Goals

PM must ensure every task remains:

1. identifiable
2. traceable
3. state-aware
4. evidence-linked
5. reviewable later

## Required Tracking Fields

For each task, PM must be able to track:

- task_id
- current_state
- target_role
- objective
- constraints
- expected_output
- validation_steps
- prerequisite_tasks
- dev_result_reference
- qa_result_reference
- final_outcome

## Tracking Rules

PM must ensure that task tracking:

- always reflects the latest explicit state
- preserves links to dev and qa evidence
- preserves prerequisite relationships
- makes pass/fail outcome visible
- supports later review without hidden assumptions

## PM Must Avoid

PM must not:

- lose linkage between task and result files
- overwrite outcome without evidence
- track tasks with ambiguous identifiers
- hide failed attempts
- mix multiple task histories into one unclear record

## Tracking Sequence

1. Register task when it is selected
2. Record delegated state
3. Attach dev result reference after execution
4. Attach qa result reference after verification
5. Update final outcome after pass/fail review
6. Preserve the full visible history for later review

## Constraints

- CURRENT_SPRINT remains the source of truth for sprint scope
- PM does not fabricate tracking data
- PM does not remove failure history
- PM does not bypass task_result.json linkage

## Evidence Rules

PM must base tracking records on:

- task JSON
- dev task_result.json
- qa task_result.json
- visible artifacts
- explicit state transitions

PM must not track lifecycle changes based on intuition alone.

## Rules

1. Always track tasks explicitly
2. Always preserve evidence linkage
3. Always preserve pass/fail history
4. Always keep identifiers stable
5. Always keep tracking reviewable

## Current Stage Behavior

At the current stage:

- human still triggers execution
- PM explicitly maintains task tracking
- dev and qa remain separate roles
- task JSON and task_result.json remain the traceable handoff artifacts

## Future Goal

This protocol will later support OpenClaw-managed task registry and auditability.