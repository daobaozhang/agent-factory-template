# Acceptance Criteria Protocol

## Purpose
Define how project-manager sets clear and verifiable acceptance criteria for each delegated task.

## Inputs

PM uses:

- CURRENT_SPRINT.json
- CURRENT_SPRINT.md
- current task objective
- expected_output
- validation_steps
- current system boundaries
- current pipeline constraints

## Acceptance Principles

PM must define acceptance criteria that are:

1. specific
2. observable
3. independently verifiable
4. aligned with task objective
5. bounded within current sprint scope

## Acceptance Requirements

Each task acceptance definition must include:

- what output must exist
- what condition must be true
- what constraint must remain respected
- what evidence must be visible
- what QA must be able to confirm

## PM Must Avoid

PM must not define acceptance criteria that are:

- vague
- subjective
- dependent on hidden knowledge
- impossible to verify
- larger than the task scope
- mixed with future work

## Acceptance Sequence

1. Read current task definition
2. Identify the exact intended outcome
3. Define the required visible output
4. Define the required validation condition
5. Define the constraints that must remain respected
6. Convert these into explicit acceptance criteria

## Constraints

- CURRENT_SPRINT remains the source of truth
- PM does not define acceptance outside task scope
- PM does not rely on implicit assumptions
- PM does not merge unrelated expectations into one task

## Evidence Rules

PM must base acceptance criteria on:

- task objective
- expected_output
- validation_steps
- current system boundaries
- visible project state

PM must not use intuition alone to define completion.

## Rules

1. Always define acceptance before execution
2. Always keep acceptance criteria explicit
3. Always keep acceptance independently verifiable
4. Always preserve sprint boundaries
5. Always keep criteria proportional to task scope

## Current Stage Behavior

At the current stage:

- human still triggers execution
- PM defines acceptance explicitly before delegation
- dev and qa remain separate roles
- task JSON remains the handoff format

## Future Goal

This protocol will later support OpenClaw-managed task acceptance and completion checks.