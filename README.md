# Claude/Codex/Gemini-to-IM

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Node.js](https://img.shields.io/badge/node-%3E%3D20-brightgreen)](https://nodejs.org)
[![GitHub Stars](https://img.shields.io/github/stars/d-wwei/Claude-Codex-Gemini-to-IM?style=social)](https://github.com/d-wwei/Claude-Codex-Gemini-to-IM)

把 AI 编程助手（Claude Code / Codex / Gemini）桥接到 IM 平台，让你在飞书、Discord、Telegram 里直接与 AI 对话、执行任务。

Bridge your AI coding assistant (Claude Code / Codex / Gemini) to IM platforms — chat with your AI directly in Feishu/Lark, Discord, or Telegram.

[中文文档](README_CN.md) 
---

## 功能特性 / Features

**核心能力 / Core**
- 在 IM 消息中直接与 Claude Code / Codex / Gemini 交互
- 后台 daemon 管理、流式回复、多会话持久化
- 权限审批流（可设为自动批准）
- 统一的附件处理：图片、文件均支持，通过本地路径注入兜底

**语音能力 / Voice（飞书专属）**
- 自动转写飞书语音消息（Ogg/Opus → PCM → 飞书 STT）
- 可选 OpenAI Whisper 作为 STT 备用
- 可选 ElevenLabs 生成语音回复

**内建会话管理 / Session Management**

| 命令 | 效果 |
|---|---|
| `/lsessions` | 列出所有活跃会话 |
| `/lsessions --all` | 列出全部会话（含已归档） |
| `/switchto <id\|name>` | 切换到指定会话 |
| `/rename <name>` | 重命名当前会话 |
| `/archive [id\|name]` | 归档会话 |
| `/unarchive <id\|name>` | 恢复归档会话 |

---

## 支持平台 / Supported Platforms

| IM 平台 | 状态 |
|---|---|
| Discord | 支持 |
| 飞书 / Feishu / Lark | 支持（含语音、附件） |
| Telegram | 支持 |
| QQ | 支持 |

## 支持的 Runtime

| Runtime | 说明 | 对应 Skill |
|---|---|---|
| `claude` | Claude Code CLI（默认） | `claude-to-im` |
| `codex` | OpenAI Codex CLI | `codex-to-im` |
| `gemini` | Gemini CLI | `gemini-to-im` |
| `auto` | 自动探测，优先级：gemini → claude → codex | 任意宿主 |

每个宿主独立隔离，有各自的配置目录：

| 宿主 | Skill 目录 | 运行时目录 |
|---|---|---|
| Claude | `~/.claude/skills/claude-to-im` | `~/.claude-to-im` |
| Codex | `~/.codex/skills/codex-to-im` | `~/.codex-to-im` |
| Gemini | `~/.gemini/skills/gemini-to-im` | `~/.gemini-to-im` |

---

## 系统要求 / Prerequisites

- **Node.js >= 20**（安装脚本会自动检测）
- **Git**
- 至少安装以下之一：
  - [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)
  - [Gemini CLI](https://github.com/google-gemini/gemini-cli)
  - [Codex CLI](https://github.com/openai/codex)
- 可选：`ffmpeg`（飞书语音转写需要）

---

## 一键安装 / Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/d-wwei/Claude-Codex-Gemini-to-IM/main/scripts/install.sh | bash
```

脚本会自动完成以下操作：
1. 检测 Node.js 版本（需 >= 20）
2. 克隆仓库到 `~/.claude/skills/claude-to-im`（已存在则 git pull）
3. 安装依赖（`npm install`）
4. 提示你运行 `claude-to-im setup` 完成配置向导

安装完成后，在 Claude Code 中运行：
```
/claude-to-im setup
```

---

## 手动安装 / Manual Install

克隆仓库：

```bash
git clone https://github.com/d-wwei/Claude-Codex-Gemini-to-IM.git ~/code/Claude-Codex-Gemini-to-IM
cd ~/code/Claude-Codex-Gemini-to-IM
npm install
```

安装对应宿主变体：

```bash
# Claude（推荐）
bash scripts/install-host.sh --host claude

# Codex
bash scripts/install-host.sh --host codex

# Gemini
bash scripts/install-host.sh --host gemini
```

安装完成后，运行 setup 完成配置：

```bash
# Claude Code 中运行
/claude-to-im setup
```

---

## 快速配置 / Quick Configuration

Setup 向导会引导你填写：
- 选择 IM 平台（Discord / 飞书 / Telegram / QQ）
- 填入 Bot Token 和相关凭据
- 选择 Runtime（claude / codex / gemini / auto）
- 设置工作目录和默认模式

配置保存在 `~/.claude-to-im/config.env`（权限 0600）。

详细配置参考：
- [使用说明](references/usage.md)（安装后可用）
- [故障排查](references/troubleshooting.md)
- [安全说明](SECURITY.md)

---

## 常用命令 / Common Commands

以下命令在 Claude Code 中执行（`/claude-to-im <subcommand>`）：

| 命令 | 说明 |
|---|---|
| `setup` | 运行配置向导 |
| `start` | 启动后台桥接 daemon |
| `stop` | 停止 daemon |
| `status` | 查看运行状态 |
| `logs` | 查看最近日志 |
| `doctor` | 诊断配置和连接问题 |
| `help` | 查看帮助 |

---

## Codex 权限档位 / Codex Permission Profiles

Codex 变体支持通过 `~/.codex-to-im/config.env` 配置权限档位：

```bash
# 完全开放（受信任环境）
CTI_CODEX_SANDBOX_MODE=danger-full-access
CTI_CODEX_APPROVAL_POLICY=never

# 安全模式
CTI_CODEX_SANDBOX_MODE=workspace-write
CTI_CODEX_APPROVAL_POLICY=on-request
```

快捷切换：

```bash
bash ~/.codex/skills/codex-to-im/scripts/permissions.sh safe
bash ~/.codex/skills/codex-to-im/scripts/permissions.sh full
```

---

## 可选依赖 / Optional Dependencies

| 功能 | 依赖 |
|---|---|
| 飞书语音转写 | `ffmpeg` + 飞书 `speech_to_text:speech` 权限 |
| OpenAI Whisper 备用 STT | `CTI_OPENAI_API_KEY` |
| ElevenLabs 语音回复 | `CTI_ELEVENLABS_API_KEY` + `CTI_ELEVENLABS_VOICE_ID` |

---

## 开发 / Development

```bash
npm install
npm test
npm run build
```

重新渲染仓库首页：

```bash
node scripts/render-host-templates.mjs --repo-home --target .
```

---

## 许可证 / License

[MIT](LICENSE)
