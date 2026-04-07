# Agent Factory Template

> Agent Factory Template = **可运行闭环模板**

一个可复制、可实例化、自带最小自动闭环的 Agent 工厂模板。

---

## 一句话说明

复制模板 → 初始化环境 → 自动执行 dev → QA → 验证 → 更新状态 → 完成

---

## 核心能力

### 1. 最小自动闭环

- `create_project.sh` — 一键创建项目
- `entrypoint.sh` — 读取环境配置，按模式启动
- `bootstrap_minimal_loop.sh` — 9 步闭环：task → dev → QA → validate → 更新 CURRENT_SPRINT
- 全程无需人工干预（qwen 模式）

### 2. 状态真源（SSOT）

- `docs/CURRENT_SPRINT.json` 是唯一状态来源
- 所有决策基于文件，不基于聊天记忆
- Workers 永不修改 CURRENT_SPRINT

### 3. 结构化结果

- Dev 输出：`runtime/artifacts/<task_id>_dev_result.json`
- QA 输出：`runtime/artifacts/<task_id>_qa_result.json`
- 最新指针：`runtime/status/task_result.json`
- Schema 校验：`runtime/scripts/validate_task_result.sh`

### 4. ENV_PROFILE 机制

- 模板只保留 `config/ENV_PROFILE.template.json`
- 实例化时自动生成 `config/ENV_PROFILE.json`
- 支持三种模式：qwen / manual / openclaw_minimal

### 5. 模板可复制

- 模板不包含任何实例化数据
- 通过 `create_project.sh` 可创建任意多个独立实例
- 每个实例有独立的环境配置和状态

---

## 使用边界

### 本模板包含

- 完整的项目初始化链路
- dev / QA 执行协议（inline 实现）
- 最小自动闭环（9 步）
- 状态管理协议（CURRENT_SPRINT SSOT）
- 结构化结果协议（task_result.json schema）
- ENV_PROFILE 环境适配机制
- 模板导出 / 复制能力

### 本模板不包含

- **OpenClaw 完整接管** — skills 的 manifest / tools 当前为角色定义占位
- **自动调度器** — `orchestrator_stub.py` 仅列出任务，不执行调度
- **平台化能力** — 无多项目管理、权限控制、审计日志
- **完整 release pipeline** — 当前通过手动导出 + 打包

### 不适用场景

- 需要生产级自动调度的场景
- 需要 OpenClaw 完整 skill/tool 映射的场景
- 需要 CI/CD 集成的场景

---

## 快速开始

```bash
# 1. 从模板创建新项目
cd /volume2/qa/projects/ppt_agent_factory
bash scripts/create_project.sh my_project

# 2. 进入新项目
cd ../my_project

# 3. 手动启动（如果创建了时跳过了自动 bootstrap）
bash scripts/entrypoint.sh
```

## 项目结构

```
/
├── config/                    # 环境配置
│   ├── template_version.json  # 模板版本
│   ├── ENV_PROFILE.template.json  # 环境配置模板
│   └── ENV_PROFILE.json       # 实例化时生成（不在模板中）
├── docs/                      # 文档和状态
│   ├── CURRENT_SPRINT.json    # 状态真源（SSOT）
│   ├── CURRENT_SPRINT.md      # 人类可读状态
│   ├── CREATE_NEW_PROJECT.md  # 使用文档
│   ├── ENV_DISCOVERY.md       # 环境探测说明
│   └── TEMPLATE_README.md     # 本文件
├── skills/                    # 角色定义和协议
│   ├── project-manager/       # PM 决策协议（14 个文件）
│   ├── dev/                   # Dev 执行协议
│   ├── qa/                    # QA 验证协议
│   └── project-bootstrap/     # 启动协调协议
├── scripts/                   # 执行脚本
│   ├── create_project.sh      # 项目创建入口
│   ├── entrypoint.sh          # 启动入口
│   ├── bootstrap_minimal_loop.sh  # 最小闭环
│   ├── run_dev_task.sh        # Dev 执行器
│   ├── run_qa_task.sh         # QA 执行器
│   ├── survey_environment.sh  # 环境探测
│   └── init_current_sprint.sh # Sprint 初始化
├── services/                  # 服务
│   ├── ppt-gateway/           # 业务入口（mock）
│   └── orchestrator_stub.py   # 调度占位
├── runtime/                   # 运行时数据
│   ├── jobs/                  # 任务定义
│   ├── artifacts/             # 任务结果（dev + qa）
│   ├── status/                # 最新状态指针
│   ├── schemas/               # JSON schema
│   └── scripts/               # 运行时脚本
├── tests/                     # 测试
└── workers/                   # Worker 目录（预留）
```

## 版本信息

- **版本**: v1.0-template
- **基线**: Phase 3 Stable
- **冻结**: 是（Phase 3 内核不再修改）
- **Git tag**: `v1.0-template`

详细发布说明见 [RELEASE_v1.0.md](./RELEASE_v1.0.md)。