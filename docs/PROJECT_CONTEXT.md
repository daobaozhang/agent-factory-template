# PROJECT CONTEXT

## Project Positioning
This project is not a single-feature app.
It is an Agent Factory for automated software development.
The current business instance is PPT Agent.

## Core Roles
- OpenClaw: project manager, task decomposition, result aggregation, sprint control
- Worker Executor: actual execution agent, currently Qwen CLI in bootstrap stage
- Codex Worker: reserved as primary developer role for future integration
- OpenCode Worker: reserved as patch/fallback role for future integration
- ppt-gateway: the only business entry point
- banana system: downstream generation engine, never direct entry point

## Four Iron Rules
1. OpenClaw is not root and cannot directly write code
2. Workers must be short-lived and task-scoped
3. ppt-gateway is the only business entry point
4. Project state must be maintained by structured files, not chat only

## State Management
The project state is maintained by:
- CURRENT_SPRINT.json (machine-readable source of truth)
- CURRENT_SPRINT.md (human-readable sprint view)

Only the project manager is allowed to update sprint state.
Workers may read sprint state, but must never modify it directly.

## Worker Delivery Rule
Each task must produce a task_result.json file as structured delivery output.
No task is considered complete without a structured result artifact.

## Docker Boundary
Allowed:
- Run task-scoped worker execution
- Access project-owned services only

Forbidden:
- docker.sock direct exposure
- privileged container
- arbitrary host mount
- operating non-project containers

For this project, if OpenClaw container interaction is required, the target container is:
- openclaw001

## Git Discipline
- main is protected
- dev is integration branch
- task/* is execution branch
- no force push
- no direct write to main

## Current Stage
Current stage is bootstrap / foundation setup.
The goal is to establish the platform before OpenClaw fully takes over orchestration.

## Current Reality
At this moment, the real controllable executor is Qwen CLI.
Therefore Qwen CLI is used to build the initial foundation of the Agent Factory.

## Standard Project Path

PROJECT_ROOT=/volume2/qa/projects/ppt_agent_factory

Notes:
- All scripts execute under this path by default
- /volume2/ai/... path is deprecated and no longer used
- QA verification and OpenClaw orchestration must use this path
- config/PROJECT_ROOT.txt contains the authoritative path