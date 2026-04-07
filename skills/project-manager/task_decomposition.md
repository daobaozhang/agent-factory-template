# Task Decomposition Protocol

## Purpose
Define how project-manager decomposes a stage goal into the smallest valid delegated tasks.

## Inputs

PM uses:

- CURRENT_SPRINT.json
- CURRENT_SPRINT.md
- current stage goal
- existing completed task records
- current system boundaries
- current pipeline constraints

## Decomposition Principles

PM must decompose work into tasks that are:

1. atomic
2. independently verifiable
3. bounded in scope
4. aligned with the current sprint stage
5. executable without unresolved prerequisites

## Task Requirements

Each decomposed task must:

- have one clear objective
- have explicit constraints
- have concrete expected_output
- have executable validation_steps
- be small enough for one dev → qa cycle

## PM Must Avoid

PM must not create tasks that are:

- vague
- multi-objective
- too large to verify cleanly
- dependent on hidden assumptions
- outside current sprint scope
- mixing implementation and verification together

## Decomposition Sequence

1. Read CURRENT_SPRINT.json
2. Identify the current stage goal
3. Break the goal into candidate sub-tasks
4. Remove oversized or blocked candidates
5. Check each candidate for verifiability
6. Keep only the smallest valid tasks
7. Convert one valid candidate into delegated task format

## Constraints

- CURRENT_SPRINT remains the source of truth
- PM does not invent work outside sprint scope
- PM does not skip prerequisite order
- PM does not merge unrelated changes into one task
- PM must preserve dev / qa role separation

## Evidence Rules

PM must base decomposition on:

- sprint definition
- already completed work
- current system state
- visible boundaries and constraints

PM must not decompose work based on intuition alone.

## Rules

1. Always decompose to the smallest valid task
2. Always keep tasks independently testable
3. Always preserve role boundaries
4. Always preserve sprint boundaries
5. Always keep progression step by step

## Current Stage Behavior

At the current stage:

- human still triggers execution
- PM decomposes and selects tasks explicitly
- dev and qa remain separate roles
- task JSON remains the handoff format

## Future Goal

This protocol will later support OpenClaw-managed stage planning and task decomposition.