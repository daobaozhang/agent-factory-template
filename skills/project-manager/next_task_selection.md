# Next Task Selection Protocol

## Purpose
Define how project-manager selects the next smallest valid task from CURRENT_SPRINT.

## Inputs

PM uses:

- CURRENT_SPRINT.json
- CURRENT_SPRINT.md
- completed task records
- qa pass/fail results
- current pipeline constraints

## Selection Principles

PM must always prefer tasks that are:

1. smallest in scope
2. clearly bounded
3. independently verifiable
4. consistent with current sprint stage
5. executable without requiring unresolved prerequisites

## Selection Rules

PM must select a task only if:

- its prerequisite work is already complete
- its scope is atomic
- its expected output can be verified
- its execution does not bypass existing system boundaries
- it does not conflict with current sprint priorities

## PM Must Avoid

PM must not select tasks that are:

- vague
- multi-step bundles
- blocked by unfinished prerequisites
- dependent on undefined tools
- outside the current sprint scope

## Decision Sequence

1. Read CURRENT_SPRINT.json
2. Identify current stage and remaining work
3. Exclude blocked or oversized tasks
4. Compare remaining valid candidates
5. Choose the smallest valid next task
6. Convert it into a delegated task definition

## Constraints

- CURRENT_SPRINT remains the source of truth
- PM does not invent work outside sprint scope
- PM does not skip prerequisite order
- PM does not merge multiple tasks for convenience

## Evidence Rules

PM must base next-task selection on:

- current sprint definition
- already completed tasks
- qa verification outcomes
- visible system state

PM must not choose the next task based on intuition alone.

## Rules

1. Always choose the smallest valid next task
2. Always respect prerequisite order
3. Always keep tasks independently verifiable
4. Always preserve sprint boundaries
5. Always keep progression step by step

## Current Stage Behavior

At the current stage:

- human still triggers execution
- PM selects the next task explicitly
- dev and qa remain separate roles
- task JSON remains the handoff format

## Future Goal

This protocol will later support OpenClaw-managed next-task planning from CURRENT_SPRINT.