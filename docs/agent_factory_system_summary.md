# Agent Factory System Summary

## Version
Phase 3 — Stable

## Date
2026-04-07

---

# 1. System Core Components

## 1.1 Project Manager (project-manager)

**Role**: Central coordinator. Reads state, makes decisions, delegates tasks, aggregates results.

**Capabilities**:
- **state_reader**: Reads CURRENT_SPRINT.json, CURRENT_SPRINT.md, and runtime/jobs/*.json. Never assumes state from chat history.
- **decision_logic**: Follows 9-step sequence: read sprint → check blockers → check next_actions → check task results → determine next step. 5 rules enforced (blockers acknowledged, smallest step, move forward on success, prepare QA on dev output, never skip structured state).
- **task_delegation**: Delegates to dev (implementation) and qa (verification). Each task has: task_id, target_role, objective, constraints, expected_output, validation_steps.
- **prompt_generator**: Converts task JSON into Qwen CLI prompt. Always includes project root path, restated objective, constraints, exact file paths, expected outputs, validation instructions.
- **task_decomposition**: Breaks stage goals into atomic, independently verifiable tasks. 7-step sequence.
- **task_prioritization**: Ranks by: dependency order, smallest executable unit, lowest risk, highest clarity, sprint alignment.
- **task_dependency_management**: Identifies prerequisites, marks blocked/unblocked, excludes blocked from selection.
- **task_state_transition**: 8 states (pending → delegated_to_dev → dev_completed → delegated_to_qa → qa_passed/qa_failed → recovery_pending → closed). 8 valid transitions only.
- **task_tracking**: Tracks 11 fields per task including task_id, current_state, dev_result_reference, qa_result_reference, final_outcome.
- **task_closure**: Closes only on QA PASS with evidence review. 5 closure conditions required.
- **failure_recovery**: On QA FAIL: reads evidence, identifies failure, creates minimal fix task, re-dispatches to dev, requires QA re-verification.
- **next_task_selection**: Selects smallest valid next task from CURRENT_SPRINT. Excludes blocked/oversized.
- **acceptance_criteria**: Defines specific, observable, independently verifiable criteria before execution.
- **orchestration_loop**: 9-step loop: read sprint → determine task → generate task JSON → dispatch dev → wait dev result → dispatch QA → wait QA result → review → update decision.

## 1.2 Dev (developer)

**Role**: Executes implementation tasks via Qwen CLI.

**Capabilities**:
- **dev_execution**: 5-step flow: read task → understand objective/constraints → translate to Qwen CLI prompt → execute → generate task_result.json.
- Must always produce task_result.json. Never modifies CURRENT_SPRINT. Only modifies allowed files.

**tools**:
- read_task_instructions (internal)
- modify_project_files (internal)
- run_basic_validation (placeholder)
- write_task_result (internal)

## 1.3 QA (quality_assurance)

**Role**: Verifies dev outputs, produces PASS/FAIL.

**Capabilities**:
- **qa_verification**: 6-step flow: read original task → read dev task_result → inspect changed files → execute/review validation steps → produce PASS/FAIL → generate task_result.json.
- PASS requires: objective completed, no constraint violation, expected output exists, validation evidence sufficient, task_result.json complete.
- FAIL triggered by: objective incomplete, constraints violated, missing output, validation not executed, task_result missing/invalid.

**tools**:
- read_dev_outputs (internal)
- validate_system_behavior (placeholder)
- check_constraints (internal)
- write_verification_result (internal)

---

# 2. State Flow

## 2.1 Core Loop

```
PM reads CURRENT_SPRINT.json
    │
    ▼
PM generates task JSON (runtime/jobs/task_XXX.json)
    │
    ▼
task JSON → dev (Qwen CLI)
    │
    ▼
dev produces: project files + task_result.json
    │
    ▼
PM reads dev task_result.json
    │
    ▼
PM dispatches to QA (Qwen CLI)
    │
    ▼
QA produces: PASS or FAIL + task_result.json
    │
    ├── PASS → PM closes task → prepares next task
    └── FAIL → PM creates fix task → re-dispatches to dev → re-QA
```

## 2.2 Step-by-Step Input/Output

| Step | Actor | Input | Output | Decision |
|------|-------|-------|--------|----------|
| 1 | PM | CURRENT_SPRINT.json | Task selection | Smallest valid next task |
| 2 | PM | Task definition | task JSON file | Delegated task with objective, constraints, expected_output, validation_steps |
| 3 | dev | task JSON | Modified files + task_result.json | Executes per constraints |
| 4 | PM | dev task_result.json | QA dispatch | Forwards to QA |
| 5 | QA | task JSON + dev task_result.json | PASS/FAIL + task_result.json | Verifies against criteria |
| 6 | PM | QA task_result.json | Close or recover | PASS → close, FAIL → fix task |

## 2.3 State Machine

```
pending ──→ delegated_to_dev ──→ dev_completed ──→ delegated_to_qa
                                                       │
                                    ┌──────────────────┴──────────────────┐
                                    ▼                                     ▼
                                qa_passed                              qa_failed
                                    │                                     │
                                    ▼                                     ▼
                                 closed                          recovery_pending
                                                                   │
                                                                   ▼
                                                        delegated_to_dev (loop)
```

---

# 3. Key File Inventory

## 3.1 Docs (Project State & Protocols)

| Path | Responsibility | Template? |
|------|---------------|-----------|
| `docs/CURRENT_SPRINT.json` | Machine-readable sprint state (SSOT). Fields: phase, sprint_goal, current_task, task_status, constraints, blockers, next_actions, last_updated, last_task_id, last_task_status, last_result_path, phase3_status | Yes |
| `docs/CURRENT_SPRINT.md` | Human-readable sprint state | Yes |
| `docs/PROJECT_CONTEXT.md` | Project positioning, roles, iron rules, state management, docker boundary, git discipline | Yes |
| `docs/TASK_RESULT_SCHEMA.md` | Task result field definitions for workers | Yes |
| `docs/PIPELINE_OVERVIEW.md` | Pipeline structure: PM → dev → QA flow | Yes |

## 3.2 Skills (Role Definitions)

| Path | Responsibility | Template? |
|------|---------------|-----------|
| `skills/project-manager/manifest.json` | PM role: project_manager, inputs/outputs | Yes |
| `skills/project-manager/tools.json` | 5 tools: read_sprint_state, read_task_results, update_sprint_state, delegate_to_dev, delegate_to_qa | Yes |
| `skills/project-manager/state_reader.md` | State reading protocol (3 sources, 5 rules) | Yes |
| `skills/project-manager/decision_logic.md` | 9-step decision sequence, 5 rules | Yes |
| `skills/project-manager/task_delegation.md` | Delegation protocol with dev/qa examples | Yes |
| `skills/project-manager/prompt_generator.md` | Prompt generation rules for Qwen CLI | Yes |
| `skills/project-manager/orchestration_loop.md` | 9-step orchestration sequence, PASS/FAIL handling | Yes |
| `skills/project-manager/failure_recovery.md` | FAIL recovery: 6-step sequence, fix task rules | Yes |
| `skills/project-manager/task_closure.md` | PASS closure: 5 conditions, 5 rules | Yes |
| `skills/project-manager/next_task_selection.md` | 5 principles, 5 rules, 6-step sequence | Yes |
| `skills/project-manager/task_decomposition.md` | 5 principles, task requirements, 7-step sequence | Yes |
| `skills/project-manager/acceptance_criteria.md` | 5 principles, acceptance requirements, 6-step sequence | Yes |
| `skills/project-manager/task_prioritization.md` | 5 principles, priority rules, 7-step sequence | Yes |
| `skills/project-manager/task_dependency_management.md` | Dependency principles, rules, 7-step review | Yes |
| `skills/project-manager/task_state_transition.md` | 8 states, 8 valid transitions | Yes |
| `skills/project-manager/task_tracking.md` | 11 tracking fields, 6-step tracking sequence | Yes |
| `skills/dev/manifest.json` | Dev role: developer, inputs/outputs | Yes |
| `skills/dev/tools.json` | 4 tools: read_task_instructions, modify_project_files, run_basic_validation, write_task_result | Yes |
| `skills/dev/dev_execution.md` | 5-step execution flow, Qwen CLI translation rules, task_result.json structure | Yes |
| `skills/qa/manifest.json` | QA role: quality_assurance, inputs/outputs | Yes |
| `skills/qa/tools.json` | 4 tools: read_dev_outputs, validate_system_behavior, check_constraints, write_verification_result | Yes |
| `skills/qa/qa_verification.md` | 6-step verification, PASS/FAIL criteria, task_result structure | Yes |

## 3.3 Services

| Path | Responsibility | Template? |
|------|---------------|-----------|
| `services/ppt-gateway/app/main.py` | FastAPI mock service (3 endpoints: POST /jobs, GET /jobs/{id}, GET /artifact/{id}) | Yes |
| `services/ppt-gateway/requirements.txt` | Dependencies: fastapi, uvicorn, pydantic | Yes |
| `services/ppt-gateway/tests/test_placeholder.py` | Placeholder test | Yes |
| `services/ppt-gateway/README.md` | Service documentation with local run example | Yes |
| `services/orchestrator_stub.py` | Placeholder orchestration entrypoint. Reads task files, lists tasks | Yes |
| `services/orchestrator_readme.md` | Stub boundaries and future replacement path | Yes |

## 3.4 Runtime (Execution State)

| Path | Responsibility | Template? |
|------|---------------|-----------|
| `runtime/schemas/task_result.schema.json` | JSON Schema for task_result validation. Required: task_id, status, summary, files_changed, error. status enum: ["success", "fail"] | Yes |
| `runtime/scripts/validate_task_result.sh` | Validation script. Parses JSON with python3 stdlib, checks required fields and status enum. Exit 0=PASS, 1=FAIL | Yes |
| `runtime/jobs/task_001.json` | Sample task: create test file under runtime/artifacts | No (example) |
| `runtime/jobs/task1_bootstrap_result.json` | Task 1 delivery: project bootstrap | No (example) |
| `runtime/jobs/task2_mock_gateway_result.json` | Task 2 delivery: mock gateway running | No (example) |
| `runtime/status/system_ready.json` | Phase 3 ready signal | Yes |
| `runtime/status/task_result.json` | Latest task execution result (overwritten per task) | Yes |
| `runtime/artifacts/test_output.txt` | Test artifact from task_001 | No (example) |
| `runtime/artifacts/task_001_result.json` | dev result for task_001 | No (example) |
| `runtime/artifacts/task_001_qa_result.json` | QA result for task_001 | No (example) |
| `runtime/artifacts/task_phase3_001_result.json` | Phase 3 task 1 result | No (example) |
| `runtime/artifacts/task_phase3_002_result.json` | Phase 3 task 2 result | No (example) |
| `runtime/artifacts/task_phase3_003_result.json` | Phase 3 task 3 result | No (example) |

## 3.5 Scripts

| Path | Responsibility | Template? |
|------|---------------|-----------|
| `scripts/run_dev_task.sh` | Dev task runner: reads task JSON → generates Qwen CLI prompt → executes | Yes |
| `scripts/run_qa_task.sh` | QA task runner: reads task + dev result → generates Qwen CLI prompt → executes | Yes |
| `scripts/run_task_pipeline.sh` | Pipeline orchestrator: chains dev → QA runners | Yes |

---

# 4. Protocol Constraints

## 4.1 task_result.json Schema

```json
{
  "required": ["task_id", "status", "summary", "files_changed", "error"],
  "properties": {
    "task_id":   { "type": "string" },
    "status":    { "type": "string", "enum": ["success", "fail"] },
    "summary":   { "type": "string" },
    "files_changed": { "type": "array", "items": { "type": "string" } },
    "error":     { "type": ["string", "null"] }
  }
}
```

**Enforcement**: `runtime/scripts/validate_task_result.sh` validates against this schema using python3 `json` standard library.

## 4.2 CURRENT_SPRINT as SSOT

CURRENT_SPRINT.json is the single source of truth for sprint state. All decisions must be based on it.

**Fields**:
- `phase`: Current phase identifier
- `sprint_goal`: Sprint objective
- `current_task`: Active task name
- `task_status`: Task status
- `constraints`: Array of active constraints
- `blockers`: Array of known blockers
- `next_actions`: Array of planned next actions
- `last_updated`: ISO timestamp
- `last_task_id`: Most recent task executed
- `last_task_status`: Status of most recent task
- `last_result_path`: Path to most recent task_result.json
- `phase3_status`: Phase 3 stability marker

**Rules**:
- Only PM modifies CURRENT_SPRINT
- Workers must never modify CURRENT_SPRINT
- No implicit state — all state is file-based
- No state from chat history

## 4.3 Forbidden Behaviors

1. Workers must not modify CURRENT_SPRINT.json or CURRENT_SPRINT.md
2. PM must not bypass task JSON handoff
3. PM must not bypass task_result.json
4. PM must not bypass QA verification
5. No parallel execution — one task at a time
6. No skipping QA after dev completion
7. No closing a task before QA PASS
8. No treating FAIL as partial PASS
9. No merging multiple tasks into one vague task
10. No assuming state without file evidence
11. No force push to main, no direct write to main
12. No docker.sock exposure, no privileged container, no arbitrary host mount

---

# 5. Verified Capabilities

## 5.1 Success Path — Verified

| Capability | Evidence |
|------------|----------|
| Project root creation | `/volume2/ai/ppt_agent_factory` created with 6 subdirectories |
| State file creation | CURRENT_SPRINT.json + .md created and maintained |
| Context documentation | PROJECT_CONTEXT.md, TASK_RESULT_SCHEMA.md, PIPELINE_OVERVIEW.md |
| Skill skeleton | 3 roles (PM/dev/QA) with README, manifest.json, tools.json |
| PM protocols | 14 protocol files created and defined |
| dev/qa protocols | dev_execution.md, qa_verification.md created |
| ppt-gateway mock service | FastAPI running on port 18081 with 3 endpoints verified via curl |
| PM → dev → QA pipeline | task_001: dev created test_output.txt → QA returned PASS |
| task_result.json generation | 8+ task_result.json files produced, all valid JSON |
| Schema definition | task_result.schema.json created with 5 required fields |
| Validation script | validate_task_result.sh created, self-tested PASS (exit 0) |
| Validation script failure mode | Tested with bad input → FAIL: Missing required field: status (exit 1) |
| Pipeline scripts | run_dev_task.sh, run_qa_task.sh, run_task_pipeline.sh created |
| Orchestrator stub | orchestrator_stub.py reads task files and lists them |
| Phase 3 initialization | system_ready.json created |
| CURRENT_SPRINT updates | 4 SSOT updates performed without data loss (fields preserved across edits) |
| FAIL injection test | task_phase3_fail_test_001: cat nonexistent file → real error captured |
| FAIL recovery test | task_phase3_repair_001: created missing file → success |
| Phase 3 closure | phase3_status: "stable" written to CURRENT_SPRINT.json |

## 5.2 Failure Recovery Path — Verified

| Step | Evidence |
|------|----------|
| FAIL injection | `cat nonexistent_test_file.txt` → exit code 1, real error message captured in task_result.json |
| PM identifies failure | task_result.json status: "fail", error field populated with real cat error |
| Repair task created | task_phase3_repair_001: created the missing file |
| Repair verified | File exists with correct content "FAIL recovery test content" |
| task_result.json produced | status: "success", files_changed lists the repaired file |

## 5.3 Multi-Task Sequential Execution — Verified

| Sequence | Tasks | Result |
|----------|-------|--------|
| Phase 1 | task1_bootstrap → task2_mock_gateway | Both produced valid task_result.json |
| Phase 2 (pipeline test) | task_001 → dev → QA PASS | Complete PM → dev → QA cycle verified |
| Phase 3 | ssot_001 → ssot_002 → schema_001 → validate_001 → validate_fix_001 → close_001 | 6 consecutive tasks, all valid, no data corruption |

---

# 6. Known Risks

## 6.1 Port Conflict

- **Issue**: Planned port 18080 is occupied by another service. ppt-gateway currently runs on 18081.
- **Impact**: Hardcoded port references must be updated if deployed to new environment.
- **Template action**: Parameterize port in docker-compose, README, and scripts.

## 6.2 Mock-Only Gateway

- **Issue**: ppt-gateway has no persistence layer. Jobs stored in-memory dict. Service restart loses all data.
- **Impact**: Not production-ready for real job tracking.
- **Template action**: Add persistence (SQLite or external DB) before template deployment.

## 6.3 No OpenClaw Integration

- **Issue**: All protocols, manifests, and tools are placeholder. No real OpenClaw skill/tool wiring exists.
- **Impact**: Current execution is manual (human triggers). OpenClaw orchestration not active.
- **Template action**: Wire manifest.json → OpenClaw skill definitions. Map tools.json to real OpenClaw tool commands.

## 6.4 No Git Integration

- **Issue**: Git discipline defined in PROJECT_CONTEXT.md but no git repository initialized. No branch workflow exists.
- **Impact**: No version control for project files.
- **Template action**: Initialize git repo, set up branch protection rules, create initial commit.

## 6.5 dev/qa tools.json are Placeholders

- **Issue**: `run_basic_validation` (dev) and `validate_system_behavior` (qa) are marked as placeholder type. No real implementation.
- **Impact**: dev/qa cannot independently execute their tools without external orchestration.
- **Template action**: Implement real tool mappings or document required external integrations.

## 6.6 Validation Script Only Checks Required Fields

- **Issue**: validate_task_result.sh checks only: JSON validity, required fields, status enum. Does not validate field types beyond JSON parsing, does not validate files_changed array content, does not cross-reference files_changed with actual filesystem.
- **Impact**: Partial schema validation.
- **Template action**: Extend to validate all property types and optional cross-references.

## 6.7 No Automated Pipeline Execution

- **Issue**: run_task_pipeline.sh only echoes commands. Does not actually execute dev → QA sequence.
- **Impact**: Pipeline is declarative only. Human must trigger each step.
- **Template action**: Add actual execution logic or integrate with OpenClaw for automated dispatch.
