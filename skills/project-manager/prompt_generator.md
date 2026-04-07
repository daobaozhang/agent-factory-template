# Prompt Generation Protocol

## Purpose
Define how project-manager converts a task into an executable Qwen CLI prompt.

## Input

PM receives:

- task (task_id, target_role, objective, constraints, expected_output, validation_steps)

## Output

PM must generate:

- A complete Qwen CLI prompt
- Ready to be executed by dev or qa

## Generation Rules

When generating a prompt:

1. Always include project root path
2. Always restate objective clearly
3. Always include constraints
4. Always specify exact file paths
5. Always define expected outputs
6. Always include validation instructions
7. Always define final output requirements

## Prompt Structure

A valid prompt must include:

- role definition (dev or qa)
- task objective
- constraints
- execution steps
- output requirements
- verification instructions

## Dev Prompt Template

- Role: Qwen CLI execution agent (dev)
- Input: task JSON
- Output: files + task_result.json

## QA Prompt Template

- Role: QA verification agent
- Input: task + dev result
- Output: PASS/FAIL + task_result.json

## Constraints

- Do not modify CURRENT_SPRINT
- Do not skip any required fields
- Do not generate incomplete prompts

## Rules

1. Prompt must be executable without modification
2. Prompt must be deterministic
3. Prompt must not require human interpretation
4. Always follow task_delegation structure