"""
Orchestrator Stub

Purpose:
Provide a minimal entry point for task orchestration before OpenClaw takes over.

Current behavior:
- Does NOT execute tasks
- Only simulates orchestration flow
"""

import json
import os

PROJECT_ROOT = "/volume2/ai/ppt_agent_factory"
JOBS_DIR = os.path.join(PROJECT_ROOT, "runtime/jobs")

def load_tasks():
    tasks = []
    for file in os.listdir(JOBS_DIR):
        if file.endswith(".json") and file.startswith("task_"):
            with open(os.path.join(JOBS_DIR, file), "r") as f:
                tasks.append(json.load(f))
    return tasks

def main():
    print("=== Orchestrator Stub ===")
    tasks = load_tasks()

    if not tasks:
        print("No tasks found.")
        return

    print(f"Found {len(tasks)} task(s):")

    for task in tasks:
        print(f"- {task.get('task_id')} (target: {task.get('target_role')})")

    print("\nNext step:")
    print("→ PM should select next task based on CURRENT_SPRINT")
    print("→ Dispatch to dev via run_dev_task.sh")
    print("→ Then dispatch to qa via run_qa_task.sh")

if __name__ == "__main__":
    main()