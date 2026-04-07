🚀 Agent Factory Template

一个用于构建 AI 自动开发系统（Agent Factory）的生产级模板。

该模板提供了一套**最小但完整可运行的任务闭环系统**：

👉 项目经理（PM） → 执行器（Dev） → QA → 状态更新 → 下一任务

---

# 🧠 这是什么？

这不是一个具体项目。

这是：

👉 **AI 自动开发“操作系统”模板**

你可以用它：

- 快速启动一个 AI 驱动开发项目
- 让任务按“一个一个”稳定执行
- 用文件系统管理状态（无隐式上下文）
- 支持未来 OpenClaw 自动接管

---

# ⚡ 核心能力

## 1️⃣ 最小任务闭环

```text
PM → 任务 → 执行 → QA → 更新状态 → 下一任务

特点：

一次只做一个任务（原子化）
所有步骤可验证
支持失败恢复（FAIL → 修复 → PASS）
2️⃣ 文件级状态管理（SSOT）

系统唯一状态来源：

docs/CURRENT_SPRINT.json

作用：

替代“聊天记忆”
支持多窗口 / 多Agent
可追踪、可恢复、可复现
3️⃣ 标准化任务结果

每个任务必须产出：

runtime/artifacts/<task_id>_dev_result.json
runtime/artifacts/<task_id>_qa_result.json

并通过 schema 校验：

runtime/schemas/task_result.schema.json
4️⃣ 环境自适应（核心设计）

通过：

config/ENV_PROFILE.json

系统会自动识别：

是否有 Qwen CLI
是否有 OpenClaw
是否支持 Docker
当前运行模式
5️⃣ 一键初始化项目
./scripts/create_project.sh my_project

执行后自动完成：

模板复制
环境检测
状态初始化
启动最小闭环（可选）
输出 READY 状态
📂 项目结构
agent_factory_template/
├── config/        # 环境配置 / 模板版本
├── docs/          # 状态与项目文档
├── skills/        # PM / Dev / QA 定义
├── runtime/       # 运行时数据（jobs / logs / artifacts）
├── scripts/       # 所有执行脚本
├── services/      # 可扩展服务层（如 gateway）
└── workspace/     # 实际开发空间
🧩 系统架构
四层设计
1️⃣ 核心调度层（PM）
project-manager skill
CURRENT_SPRINT 驱动
任务选择与推进
2️⃣ 执行层（Dev）
Qwen CLI（默认）
shell（fallback）
可扩展 Codex / OpenCode
3️⃣ 环境层
ENV_PROFILE.json
bootstrap_mode 控制行为
4️⃣ 运行层
runtime/jobs
runtime/artifacts
runtime/logs
🔧 使用流程（非常重要）
Step 1：创建项目
./scripts/create_project.sh my_project

可选：

./scripts/create_project.sh my_project --no-bootstrap
Step 2：环境调研
scripts/survey_environment.sh

生成：

config/ENV_PROFILE.json
Step 3：系统启动
scripts/entrypoint.sh
Step 4：最小闭环执行
scripts/bootstrap_minimal_loop.sh

执行流程：

创建任务
Dev 执行
QA 校验
schema 验证
更新 CURRENT_SPRINT
⚙️ 启动模式说明
模式	行为
qwen	全自动执行
manual	输出操作步骤
openclaw_minimal	等待 OpenClaw 接管
📦 模板 vs 项目
模板包含：
系统架构
调度逻辑
skill 定义
runtime 机制
模板不包含：
业务逻辑（如 PPT 生成）
API 实现
项目专属 prompt
特定服务配置
🛑 使用规则（必须遵守）
CURRENT_SPRINT.json 是唯一真源
Worker 不允许修改 CURRENT_SPRINT
一次只允许一个任务
所有任务必须可验证
禁止隐式状态
🧪 系统验证

运行：

bash scripts/entrypoint.sh

如果输出：

READY

说明系统正常

🔮 后续扩展方向
OpenClaw 全自动接管
多 Agent 并发执行
Docker Worker 调度
持久化服务层（Gateway）
🧠 设计理念

👉 让 AI 开发：

可控（deterministic）
可追踪（traceable）
可复现（reproducible）
🏁 最后一句话

这个模板的目标不是“更智能”，而是：

👉 让 AI 开发变得稳定、可控、可复制



# 🧠 我给你的真实评价（很重要）

你现在 README 最大的问题通常是：

### ❌ 太像“内部设计文档”
别人看完还是不知道：

👉 怎么开始用

---

### ❌ 缺少“入口”
必须有：

```bash
./scripts/create_project.sh
❌ 没有讲清楚“这是啥”

👉 工具？框架？demo？项目？

🎯 这版帮你解决了
一眼知道是什么（AI开发操作系统）
一条命令启动
架构清晰
流程清晰
模板边界清晰
可扩展路径清晰
