# Task Prioritization Protocol

## Purpose
Define how project-manager prioritizes multiple valid candidate tasks.

## Inputs

PM uses:

- CURRENT_SPRINT.json
- CURRENT_SPRINT.md
- candidate tasks from decomposition
- completed task records
- qa results
- system constraints
- pipeline state

## Prioritization Principles

PM must prioritize tasks based on:

1. dependency order (prerequisites first)
2. smallest executable unit
3. lowest risk
4. highest clarity
5. strongest alignment with current sprint stage

## Priority Rules

A task should be prioritized higher if:

- it unblocks other tasks
- it has no unresolved dependencies
- it is independently verifiable
- it fits within current system boundaries
- it reduces system uncertainty

## PM Must Avoid

PM must not prioritize tasks that are:

- blocked by unfinished work
- vague or poorly defined
- too large to verify cleanly
- dependent on undefined tools
- outside current sprint scope

## Decision Sequence

1. Read CURRENT_SPRINT.json
2. List all valid candidate tasks
3. Remove blocked or oversized tasks
4. Evaluate remaining tasks against prioritization principles
5. Rank tasks
6. Select the highest-priority task
7. Convert it into delegated task format

## Constraints

- CURRENT_SPRINT remains the source of truth
- PM does not reorder tasks arbitrarily
- PM does not skip prerequisite order
- PM does not merge tasks for convenience

## Evidence Rules

PM must base prioritization on:

- sprint definition
- dependency structure
- completed tasks
- qa outcomes
- visible system state

PM must not prioritize based on intuition alone.

## Rules

1. Always respect dependency order
2. Always prefer the smallest valid task
3. Always reduce system uncertainty first
4. Always preserve sprint boundaries
5. Always keep progression step by step

## Current Stage Behavior

At the current stage:

- human still triggers execution
- PM explicitly ranks candidate tasks
- dev and qa remain separate roles
- task JSON remains the handoff format

## Future Goal

This protocol will later support OpenClaw-managed task prioritization and scheduling.