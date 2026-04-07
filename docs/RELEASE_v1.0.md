# Agent Factory Template — Release v1.0

## Metadata

- **Version**: v1.0-template
- **Baseline**: Phase 3 Stable
- **Release Date**: 2026-04-07
- **Commit**: `3f69a58` (tagged `v1.0-template`)
- **Repository**: `/volume2/qa/projects/ppt_agent_factory`
- **Standard Path**: `/volume2/qa/projects/ppt_agent_factory`

---

## A. 当前能力

本版本已具备以下真实可验证能力：

### 1. 项目初始化链路

- `create_project.sh` — 完整项目创建脚本，支持以下参数：
  - `<project_name>` — 项目名称
  - `[target_path]` — 目标目录
  - `--no-bootstrap` — 仅复制模板，不自动执行 entrypoint
  - `--bootstrap-mode=<qwen|manual|openclaw_minimal>` — 强制指定启动模式
- 创建流程：复制模板 → 生成 template_version.json → 环境探测 → 生成 ENV_PROFILE.json → git init → 初始化 sprint 状态 → entrypoint（可选）
- `survey_environment.sh` — 自动检测环境（NAS/docker/executor/端口/容器），生成 ENV_PROFILE.json
- `init_current_sprint.sh` — 初始化 CURRENT_SPRINT.json/.md、system_ready.json、task_result.json

### 2. 真实最小闭环

- `bootstrap_minimal_loop.sh` — 9 步自动闭环：
  1. 基础设施检查
  2. 生成 task JSON
  3. 调用 run_dev_task.sh
  4. 读取 dev_result.json
  5. 调用 run_qa_task.sh
  6. 读取 qa_result.json
  7. 运行 validate_task_result.sh（schema 校验）
  8. 更新 CURRENT_SPRINT.json
  9. 输出 PASS / FAIL
- `entrypoint.sh` — 读取 ENV_PROFILE.json，按 bootstrap.mode 分支执行

### 3. Dev → QA → Validate → CURRENT_SPRINT 更新 → task_result 流转

- `run_dev_task.sh` — 执行 dev 工作，写入结构化结果到 `runtime/artifacts/<task_id>_dev_result.json`
- `run_qa_task.sh` — 执行 QA 验证，写入结构化结果到 `runtime/artifacts/<task_id>_qa_result.json`
- `runtime/status/task_result.json` — 作为 latest pointer，记录最新任务结果
- `validate_task_result.sh` — 基于 schema 校验 task_result.json（JSON 有效性、required 字段、status 枚举）
- `bootstrap_minimal_loop.sh` — 闭环完成后自动更新 CURRENT_SPRINT.json 的 `last_task_id`、`last_task_status`、`last_result_path`、`last_updated`

### 4. Artifacts 分流

- dev 结果：`runtime/artifacts/<task_id>_dev_result.json`
- QA 结果：`runtime/artifacts/<task_id>_qa_result.json`
- 不再覆盖单一 task_result.json，每个角色独立输出

### 5. ENV_PROFILE 机制已固化

- 模板中仅保留 `config/ENV_PROFILE.template.json`
- `config/ENV_PROFILE.json` 仅在实例化时由 `survey_environment.sh` 生成
- 支持三种 bootstrap.mode：qwen / manual / openclaw_minimal

### 6. 模板导出已去污染

- 导出包（v2）不包含 ENV_PROFILE.json 实例文件
- 导出包包含：完整源码目录、压缩包、MANIFEST.txt、SHA256SUMS.txt、EXPORT_REPORT.md
- 可通过 `create_project.sh` 从模板创建新的项目实例

---

## B. Freeze 说明

### 版本状态

当前版本为 **v1.0-template**，已进入 **Freeze** 状态。

### 冻结内容

以下组件与协议在本版本中冻结，不再修改：

1. **Phase 3 内核** — project-manager 的 14 个决策协议文件（state_reader / decision_logic / task_delegation / prompt_generator / orchestration_loop / failure_recovery / task_closure / next_task_selection / task_decomposition / acceptance_criteria / task_prioritization / task_dependency_management / task_state_transition / task_tracking）保持不变
2. **dev / qa 执行协议** — dev_execution.md / qa_verification.md 保持不变
3. **CURRENT_SPRINT 为唯一状态真源（SSOT）** — 所有决策基于 CURRENT_SPRINT.json，不允许隐式状态
4. **task_result 结构化结果协议** — 字段定义（task_id / status / summary / files_changed / error）冻结，status 枚举值限定为 ["success", "fail"]
5. **task_result.json schema** — `runtime/schemas/task_result.schema.json` 冻结
6. **Artifacts 分流约定** — dev 输出到 `*_dev_result.json`，QA 输出到 `*_qa_result.json`，latest pointer 为 `runtime/status/task_result.json`

### 版本定位

这是 **模板基座（Template Baseline）**，不是继续开发中的原型。
后续版本迭代应基于此模板创建分支或新版本，不得直接修改本版本内容。

---

## C. 不包含内容

当前版本 **暂不包含** 以下能力，不在 v1.0 范围内：

1. **OpenClaw 完整接管** — skills 的 manifest.json / tools.json 当前为角色定义占位，尚未映射到 OpenClaw 真实 skill 与 tool 命令
2. **自动调度器 / orchestrator** — `orchestrator_stub.py` 仅读取 task 文件并列出，不执行真实调度；自动调度逻辑待后续版本实现
3. **tools.json 完全执行化** — `run_basic_validation`（dev）与 `validate_system_behavior`（qa）仍为 placeholder 类型，无真实实现
4. **完整 release pipeline** — 当前通过手动导出 + tar.gz 打包，尚未实现自动化构建与发布流水线
5. **平台化高级能力** — 包括但不限于：多项目并行管理、权限控制、审计日志、CI/CD 集成、跨项目任务依赖图

上述能力将在后续版本中按优先级逐步实现，不属于 v1.0-template 交付范围。