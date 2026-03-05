# Claude-to-IM Skill

Bridge Claude Code to IM platforms — chat with Claude from Telegram, Discord, or Feishu/Lark.

将 Claude Code 桥接到 IM 平台 —— 在 Telegram、Discord 或飞书中与 Claude 对话。

---

## How It Works / 工作原理

This skill runs a background daemon that connects your IM bots to Claude Code sessions. Messages from IM are forwarded to Claude Code, and responses (including tool use, permission requests, streaming previews) are sent back to your chat.

本 Skill 运行一个后台守护进程，将你的 IM 机器人连接到 Claude Code 会话。来自 IM 的消息被转发给 Claude Code，响应（包括工具调用、权限请求、流式预览）会发回到聊天中。

```
You (Telegram/Discord/Feishu)
  ↕ Bot API
Background Daemon (Node.js)
  ↕ Claude Agent SDK
Claude Code → reads/writes your codebase
```

## Features / 功能特点

- **Three IM platforms** — Telegram, Discord, Feishu/Lark, enable any combination
- **Interactive setup** — guided wizard collects tokens with step-by-step instructions
- **Permission control** — tool calls require explicit approval via inline buttons in chat
- **Streaming preview** — see Claude's response as it types (Telegram & Discord)
- **Session persistence** — conversations survive daemon restarts
- **Secret protection** — tokens stored with `chmod 600`, auto-redacted in all logs
- **Zero code required** — install the skill and run `/claude-to-im setup`, that's it

---

- **三大 IM 平台** — Telegram、Discord、飞书，可任意组合启用
- **交互式配置** — 引导式向导逐步收集 token，附带详细获取说明
- **权限控制** — 工具调用需要在聊天中通过内联按钮明确批准
- **流式预览** — 实时查看 Claude 的输出（Telegram 和 Discord 支持）
- **会话持久化** — 对话在守护进程重启后保留
- **密钥保护** — token 以 `chmod 600` 存储，日志中自动脱敏
- **无需编写代码** — 安装 Skill 后运行 `/claude-to-im setup` 即可

## Prerequisites / 前置要求

- **Node.js >= 20**
- **Claude Code CLI** — installed and authenticated (`claude` command available)

## Installation / 安装

### Recommended / 推荐方式

```bash
npx skills add https://github.com/op7418/Claude-to-IM-skill.git --skill claude-to-im
```

### Alternative: Manual clone / 手动克隆

```bash
# Clone the repo / 克隆仓库
git clone https://github.com/op7418/Claude-to-IM-skill.git

# Symlink into skills directory / 创建符号链接
mkdir -p ~/.claude/skills
ln -s "$(pwd)/Claude-to-IM-skill" ~/.claude/skills/claude-to-im
```

After installation, restart Claude Code or start a new session for the skill to load.

安装后重启 Claude Code 或开启新会话，Skill 即可加载。

## Quick Start / 快速开始

### 1. Setup / 配置

```
/claude-to-im setup
```

The wizard will guide you through:

向导会引导你完成以下步骤：

1. **Choose channels** — pick Telegram, Discord, Feishu, or any combination
2. **Enter credentials** — the wizard explains exactly where to get each token, which settings to enable, and what permissions to grant
3. **Set defaults** — working directory, model, and mode
4. **Validate** — tokens are verified against platform APIs immediately

选择渠道 → 输入凭据（向导会详细说明如何获取每个 token、需要开启哪些设置、授予哪些权限）→ 设置默认值 → 自动验证 token

### 2. Start / 启动

```
/claude-to-im start
```

The daemon starts in the background. You can close the terminal — it keeps running.

守护进程在后台启动。关闭终端后仍会继续运行。

### 3. Chat / 开始聊天

Open your IM app and send a message to your bot. Claude Code will respond.

打开 IM 应用，给你的机器人发消息，Claude Code 会回复。

When Claude needs to use a tool (edit a file, run a command), you'll see a permission prompt with **Allow** / **Deny** buttons right in the chat.

当 Claude 需要使用工具（编辑文件、运行命令）时，聊天中会弹出带有 **Allow** / **Deny** 按钮的权限请求。

## Commands / 命令列表

All commands are run inside Claude Code CLI:

所有命令在 Claude Code CLI 中执行：

| Command / 命令 | Description / 说明 |
|---|---|
| `/claude-to-im setup` | Interactive setup wizard / 交互式配置向导 |
| `/claude-to-im start` | Start the bridge daemon / 启动桥接守护进程 |
| `/claude-to-im stop` | Stop the bridge daemon / 停止守护进程 |
| `/claude-to-im status` | Show daemon status (PID, uptime, channels) / 查看运行状态 |
| `/claude-to-im logs` | Show last 50 log lines (secrets auto-redacted) / 查看最近 50 行日志 |
| `/claude-to-im logs 200` | Show last 200 log lines / 查看最近 200 行日志 |
| `/claude-to-im reconfigure` | Update config interactively / 交互式修改配置 |
| `/claude-to-im doctor` | Diagnose issues (Node version, permissions, token validity) / 诊断问题 |

## Platform Setup Guides / 平台配置指南

The `setup` wizard provides inline guidance for every step. Here's a summary:

`setup` 向导会在每一步提供内联指引，以下是概要：

### Telegram

1. Message `@BotFather` on Telegram → `/newbot` → follow prompts
2. Copy the bot token (format: `123456789:AABbCc...`)
3. Recommended: `/setprivacy` → Disable (for group use)
4. Find your User ID: message `@userinfobot`

在 Telegram 中搜索 `@BotFather` → `/newbot` → 按提示操作 → 复制 token。建议关闭 Privacy Mode（用于群组）。通过 `@userinfobot` 获取你的 User ID。

### Discord

1. Go to [Discord Developer Portal](https://discord.com/developers/applications) → New Application
2. Bot tab → Reset Token → copy it
3. Enable **Message Content Intent** under Privileged Gateway Intents
4. OAuth2 → URL Generator → scope `bot` → permissions: Send Messages, Read Message History, View Channels → copy invite URL

前往 [Discord 开发者门户](https://discord.com/developers/applications) → 新建应用 → Bot 标签页获取 token → 开启 Message Content Intent → OAuth2 生成邀请链接。

### Feishu / Lark / 飞书

1. Go to [Feishu Open Platform](https://open.feishu.cn/app) (or [Lark](https://open.larksuite.com/app))
2. Create Custom App → get App ID and App Secret
3. Add permissions: `im:message`, `im:message.group_at_msg`, `im:resource`
4. Enable Bot feature → publish and approve

前往[飞书开放平台](https://open.feishu.cn/app) → 创建自建应用 → 获取 App ID 和 App Secret → 添加权限 `im:message` 等 → 启用机器人 → 发布审核。

## Architecture / 架构

```
~/.claude-to-im/           ← User data directory / 用户数据目录
├── config.env             ← Credentials & settings (chmod 600)
├── data/                  ← Persistent JSON storage
│   ├── sessions.json
│   ├── bindings.json
│   ├── permissions.json
│   └── messages/          ← Per-session message history
├── logs/
│   └── bridge.log         ← Auto-rotated, secrets redacted
└── runtime/
    ├── bridge.pid          ← Daemon PID file
    └── status.json         ← Current status
```

### Key components / 核心组件

| Component / 组件 | Role / 职责 |
|---|---|
| `src/main.ts` | Daemon entry — assembles DI, starts bridge / 守护进程入口，组装依赖注入 |
| `src/config.ts` | Load/save `config.env`, map to bridge settings / 配置加载保存 |
| `src/store.ts` | JSON file BridgeStore (30 methods, write-through cache) / JSON 文件存储 |
| `src/llm-provider.ts` | Claude Agent SDK `query()` → SSE stream / SDK 调用转 SSE 流 |
| `src/permission-gateway.ts` | Async bridge: SDK `canUseTool` ↔ IM buttons / 权限异步桥接 |
| `src/logger.ts` | Secret-redacted file logging with rotation / 脱敏日志 |
| `scripts/daemon.sh` | Process management (start/stop/status/logs) / 进程管理 |
| `scripts/doctor.sh` | Health checks / 诊断检查 |
| `SKILL.md` | Claude Code skill definition / Skill 定义文件 |

### Permission flow / 权限流程

```
1. Claude wants to use a tool (e.g., Edit file)
2. SDK calls canUseTool() → LLMProvider emits permission_request SSE
3. Bridge sends inline buttons to IM chat: [Allow] [Deny]
4. canUseTool() blocks, waiting for user response (5 min timeout)
5. User taps Allow → bridge resolves the pending permission
6. SDK continues tool execution → result streamed back to IM
```

```
1. Claude 想使用工具（如编辑文件）
2. SDK 调用 canUseTool() → LLMProvider 发射 permission_request SSE 事件
3. Bridge 在 IM 聊天中发送内联按钮：[允许] [拒绝]
4. canUseTool() 阻塞等待用户响应（5 分钟超时）
5. 用户点击允许 → Bridge 解除权限等待
6. SDK 继续执行工具 → 结果流式发回 IM
```

## Troubleshooting / 故障排查

Run diagnostics:

运行诊断：

```
/claude-to-im doctor
```

This checks: Node.js version, config file existence and permissions, token validity (live API calls), log directory, PID file consistency, and recent errors.

检查项目：Node.js 版本、配置文件是否存在及权限、token 有效性（实时 API 调用）、日志目录、PID 文件一致性、最近的错误。

Common issues / 常见问题：

| Issue / 问题 | Solution / 解决方案 |
|---|---|
| `Bridge won't start` | Run `doctor`. Check if Node >= 20. Check logs. / 运行 `doctor`，检查 Node 版本和日志 |
| `Messages not received` | Verify token with `doctor`. Check allowed users config. / 用 `doctor` 验证 token，检查允许用户配置 |
| `Permission timeout` | User didn't respond within 5 min. Tool call auto-denied. / 用户 5 分钟内未响应，工具调用自动拒绝 |
| `Stale PID file` | Run `stop` then `start`. daemon.sh auto-cleans stale PIDs. / 运行 `stop` 再 `start`，脚本会自动清理 |

See [docs/troubleshooting.md](docs/troubleshooting.md) for more details.

详见 [docs/troubleshooting.md](docs/troubleshooting.md)。

## Security / 安全

- All credentials stored in `~/.claude-to-im/config.env` with `chmod 600`
- Tokens are automatically redacted in all log output (pattern-based masking)
- Allowed user/channel/guild lists restrict who can interact with the bot
- The daemon is a local process with no inbound network listeners
- See [SECURITY.md](SECURITY.md) for threat model and incident response

---

- 所有凭据存储在 `~/.claude-to-im/config.env`，权限 `chmod 600`
- 日志输出中 token 自动脱敏（基于正则匹配）
- 允许用户/频道/服务器列表限制谁可以与机器人交互
- 守护进程是本地进程，没有入站网络监听
- 详见 [SECURITY.md](SECURITY.md) 了解威胁模型和应急响应

## Development / 开发

```bash
# Install dependencies / 安装依赖
npm install

# Run in dev mode / 开发模式运行
npm run dev

# Type check / 类型检查
npm run typecheck

# Run tests / 运行测试
npm test

# Build bundle / 构建打包
npm run build
```

## License / 许可

[MIT](LICENSE)
