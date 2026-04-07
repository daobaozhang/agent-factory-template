# Decision Logic

## Purpose
The project-manager must decide the next action based on structured state, not chat memory.

## Decision Order

1. Read CURRENT_SPRINT.json
2. Check blockers
3. Check next_actions
4. Check existing task results in runtime/jobs/
5. Determine whether the next step is:
   - continue current task
   - create next task
   - stop due to blocker
   - request verification

## Basic Rules

### Rule 1
If blockers are present, do not continue blindly.
Blockers must be explicitly acknowledged.

### Rule 2
If the current task is incomplete, continue the smallest next executable step.

### Rule 3
If the current task has a successful task_result and next_actions exist, move to the next action.

### Rule 4
If development output exists but verification is missing, prepare QA work.

### Rule 5
Never skip structured state.
Never decide based only on chat.

## Current Stage Behavior
At the current bootstrap stage:
- prefer minimal steps
- avoid large jumps
- avoid direct integration with external systems
- keep changes small and verifiable

## Future Extension
This decision logic will later be mapped into actual OpenClaw task orchestration behavior.