🚀 Agent Factory Template

> 🧠 一个将 AI 开发流程工程化的模板，实现 
> —— 让 AI 项目具备「执行、验证、状态、闭环」
如：
OpenClaw（PM）
 ↓
project-manager skill
 ↓
Worker 调度（Codex / claude）
 ↓
workspace + Git
 ↓
agent-gateway
 ↓
agent-client / agent-slides
 ↓
agent / JSON / Markdown / Logs

## 📌 这是什么？

Agent Factory Template 是一个：

> 👉 **AI开发流程操作系统（Agent Development OS）模板**

它不是简单的代码模板，而是一套：

```text
任务驱动 → 执行 → QA验证 → 状态更新 → 持续推进

的完整运行机制。

❗ 为什么需要这个？

传统 AI 项目通常是这样：

写 prompt → 生成结果 → 人工判断 → 再改 prompt

问题：

❌ 没有流程
❌ 没有验证
❌ 没有状态
❌ 无法规模化
✅ 本模板解决的问题

Agent Factory Template 把 AI 开发变成：

可执行的工程流程

具体能力：

1️⃣ 强制闭环（核心）
Task → Dev → QA → Validate → 状态更新

👉 每一步都有输入 / 输出
👉 必须验证才能进入下一步

2️⃣ 单一状态真源（SSOT）

所有状态统一写入：

CURRENT_SPRINT.json

👉 不允许隐式状态
👉 所有决策基于真实数据

3️⃣ 结构化结果（机器可判断）
{
  "task_id": "...",
  "status": "success | fail",
  "summary": "...",
  "files_changed": [],
  "error": null
}

👉 AI 输出不再是“文本”
👉 而是“可执行结果”

4️⃣ Dev / QA 分离
Dev 负责实现
QA 负责验证

👉 避免“AI自己说自己对”

5️⃣ 模板化复制能力

你可以：

bash scripts/create_project.sh my_project

👉 一键创建一个完整 AI 项目（含流程）

⚡ 快速开始
git clone --branch v1.0-template https://github.com/daobaozhang/agent-factory-template.git
cd agent-factory-template
bash scripts/create_project.sh my_project
🧭 第一次运行会发生什么？

系统会自动：

环境检测（ENV_PROFILE）
初始化状态（CURRENT_SPRINT）
生成任务
执行 Dev
执行 QA
校验结果
更新状态
输出 PASS / FAIL
⚙️ 运行模式
模式	说明
任何编码工具 	自动执行（推荐）
manual	手动执行
openclaw_minimal	最小接入 OpenClaw
🧱 项目结构
agent-factory-template/
├── scripts/      # 流程控制（闭环入口）
├── skills/       # Agent 行为定义
├── runtime/      # 状态 + 结果
├── config/       # 环境配置
├── docs/         # 使用说明
🎯 适用场景

这个模板适用于：

AI Agent 系统开发
自动化开发流程
Prompt 工程升级为工程系统
多 Agent 协作系统
AI + QA 验证闭环
⚠️ 当前版本说明
Version: v1.0-template
Status: Freeze（稳定基座）
✅ 已支持
自动闭环流程
状态管理（SSOT）
QA 验证机制
模板复制能力
❌ 暂不支持（刻意控制复杂度）
自动调度系统
OpenClaw 完整接管
平台 UI
CI/CD
📖 文档
docs/CREATE_NEW_PROJECT.md → 如何创建项目
docs/ENV_DISCOVERY.md → 环境说明
docs/TEMPLATE_README.md → 模板细节
🧠 一句话总结

这是一个把 AI 开发从“写 prompt”升级为“跑工程流程”的模板

👤 作者daobaozhang
