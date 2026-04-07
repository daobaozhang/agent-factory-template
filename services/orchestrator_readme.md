# Orchestrator Stub README

## Purpose
Document the role of orchestrator_stub.py in the current stage of the system.

## Current Role

orchestrator_stub.py is a placeholder orchestration entrypoint.

At the current stage, it only:

- reads task files from runtime/jobs
- lists available tasks
- shows the expected next execution sequence

It does not:

- select tasks automatically
- execute dev
- execute qa
- modify CURRENT_SPRINT
- make real orchestration decisions

## Current Execution Relationship

Current flow is:

PM decision
→ task JSON
→ orchestrator_stub.py reads tasks
→ human triggers run_dev_task.sh
→ human triggers run_qa_task.sh

## Boundaries

The stub must remain:

- read-only
- non-destructive
- non-executing
- easy to replace later by OpenClaw orchestration

## Why It Exists

This stub exists to:

1. reserve a clear orchestration entrypoint
2. make the future takeover path explicit
3. avoid mixing orchestration logic into dev or qa roles

## Future Replacement

Later, this stub may be replaced by:

- OpenClaw-managed orchestration
- skill-driven task dispatch
- tool-mapped worker execution

## Rules

1. Do not put implementation logic here
2. Do not put qa logic here
3. Do not bypass task JSON
4. Do not bypass task_result.json
5. Keep orchestration responsibility separate