# Task Dependency Management Protocol

## Purpose
Define how project-manager manages task dependencies to preserve correct execution order.

## Inputs

PM uses:

- CURRENT_SPRINT.json
- CURRENT_SPRINT.md
- candidate tasks
- completed task records
- qa pass/fail results
- current system boundaries
- pipeline state

## Dependency Principles

PM must treat a task as dependent when:

1. it requires an output from another task
2. it requires a previously verified system state
3. it cannot be executed safely in isolation
4. it would bypass the intended sprint order if started early

## Dependency Rules

For each candidate task, PM must determine:

- prerequisite tasks
- whether prerequisites are completed
- whether prerequisites are verified by qa
- whether any blocking failure still exists

A task is executable only if all required prerequisites are complete and verified.

## PM Must Avoid

PM must not:

- dispatch tasks with unresolved prerequisites
- assume dependency completion without evidence
- hide multiple dependencies inside vague wording
- bypass qa verification of prerequisite work
- treat partial prerequisite completion as sufficient

## Dependency Review Sequence

1. Read CURRENT_SPRINT.json
2. List candidate tasks
3. Identify prerequisite relationships
4. Mark blocked and unblocked tasks
5. Exclude blocked tasks from selection
6. Keep only tasks with satisfied dependencies
7. Continue prioritization among valid tasks

## Constraints

- CURRENT_SPRINT remains the source of truth
- PM does not invent dependencies outside visible system logic
- PM does not ignore prerequisite order for convenience
- PM does not merge dependency resolution into unrelated tasks

## Evidence Rules

PM must base dependency decisions on:

- sprint definition
- task outputs
- dev task_result.json
- qa task_result.json
- visible system state

PM must not rely on intuition alone.

## Rules

1. Always identify prerequisites explicitly
2. Always require prerequisite verification
3. Always exclude blocked tasks
4. Always preserve sprint boundaries
5. Always keep execution order traceable

## Current Stage Behavior

At the current stage:

- human still triggers execution
- PM explicitly reviews dependencies before task selection
- dev and qa remain separate roles
- task JSON remains the handoff format

## Future Goal

This protocol will later support OpenClaw-managed dependency-aware planning and scheduling.