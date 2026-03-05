---
name: claude-to-im
description: |
  Bridge Claude Code to IM platforms (Telegram, Discord, Feishu/Lark).
  Start a background daemon that forwards IM messages to Claude Code sessions.
  Commands: setup, start, stop, status, logs, reconfigure, doctor
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - AskUserQuestion
  - Grep
  - Glob
---

# Claude-to-IM Bridge Skill

You are managing the Claude-to-IM bridge. The skill directory is at `$SKILL_DIR`.
User data is stored at `~/.claude-to-im/`.

Parse the first word of `$ARGUMENTS` as the subcommand.

## Subcommands

### `setup`

Run an interactive setup wizard. For every step that asks the user for input, include clear guidance text explaining where to get the value, what options to choose, and what format to use. Present each question with AskUserQuestion.

**Step 1 — Choose channels**

Ask which channels to enable (telegram, discord, feishu). Accept comma-separated input. Include this guidance:

> Supported channels:
> - **telegram** — Best for personal use. Supports inline permission buttons, streaming preview, and file attachments.
> - **discord** — Good for team use. Supports server/channel/user-level access control.
> - **feishu** (Lark) — For teams using Feishu/Lark. Supports event-based messaging.
>
> You can enable multiple channels, e.g. `telegram,discord`

**Step 2 — Collect tokens per channel**

For each enabled channel, ask for the required credentials with detailed guidance:

#### Telegram

Ask for **Bot Token** with this guidance:

> **How to get a Telegram Bot Token:**
> 1. Open Telegram and search for `@BotFather`
> 2. Send `/newbot` to create a new bot
> 3. Follow the prompts: choose a display name and a username (must end in `bot`)
> 4. BotFather will reply with a token like `7823456789:AAF-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
> 5. Copy the full token and paste it here
>
> **Recommended bot settings** (send these commands to @BotFather):
> - `/setprivacy` → choose your bot → `Disable` (so the bot can read group messages, only needed for group use)
> - `/setcommands` → set commands like `new - Start new session`, `mode - Switch mode`
>
> Token format: `数字:字母数字字符串` (e.g. `7823456789:AAF-xxx...xxx`)

Then ask for **Allowed User IDs** (optional) with this guidance:

> **How to find your Telegram User ID:**
> 1. Search for `@userinfobot` on Telegram and start a chat
> 2. It will reply with your User ID (a number like `123456789`)
> 3. Alternatively, forward a message from yourself to `@userinfobot`
>
> Enter comma-separated IDs to restrict access (recommended for security).
> Leave empty to allow anyone who can message the bot.

#### Discord

Ask for **Bot Token** with this guidance:

> **How to create a Discord Bot and get the token:**
> 1. Go to https://discord.com/developers/applications
> 2. Click **"New Application"** → give it a name → click **"Create"**
> 3. Go to the **"Bot"** tab on the left sidebar
> 4. Click **"Reset Token"** → copy the token (you can only see it once!)
>
> **Required bot settings (on the Bot tab):**
> - Under **Privileged Gateway Intents**, enable:
>   - ✅ **Message Content Intent** (required to read message text)
>
> **Invite the bot to your server:**
> 1. Go to the **"OAuth2"** tab → **"URL Generator"**
> 2. Under **Scopes**, check: `bot`
> 3. Under **Bot Permissions**, check: `Send Messages`, `Read Message History`, `View Channels`
> 4. Copy the generated URL at the bottom and open it in your browser
> 5. Select the server and click **"Authorize"**
>
> Token format: a long base64-like string (e.g. `MTIzNDU2Nzg5.Gxxxxx.xxxxxxxxxxxxxxxxxxxxxxxx`)

Then ask for **Allowed User IDs** (optional):

> **How to find Discord User IDs:**
> 1. In Discord, go to Settings → Advanced → enable **Developer Mode**
> 2. Right-click on any user → **"Copy User ID"**
>
> Enter comma-separated IDs. Leave empty to allow anyone in the server.

Then ask for **Allowed Channel IDs** (optional):

> **How to find Discord Channel IDs:**
> 1. With Developer Mode enabled, right-click on any channel → **"Copy Channel ID"**
>
> Enter comma-separated IDs to restrict the bot to specific channels.
> Leave empty to allow all channels the bot can see.

Then ask for **Allowed Guild (Server) IDs** (optional):

> **How to find Discord Server IDs:**
> 1. With Developer Mode enabled, right-click on the server icon → **"Copy Server ID"**
>
> Enter comma-separated IDs. Leave empty to allow all servers the bot is in.

#### Feishu / Lark

Ask for **App ID** and **App Secret** with this guidance:

> **How to create a Feishu/Lark app and get credentials:**
> 1. Go to Feishu: https://open.feishu.cn/app or Lark: https://open.larksuite.com/app
> 2. Click **"Create Custom App"**
> 3. Fill in the app name and description → click **"Create"**
> 4. On the app's **"Credentials & Basic Info"** page, find:
>    - **App ID** (like `cli_xxxxxxxxxx`)
>    - **App Secret** (click to reveal, like `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`)
>
> **Required permissions (under "Permissions & Scopes"):**
> - `im:message` — Send and receive messages
> - `im:message.group_at_msg` — Receive @ mentions in groups
> - `im:resource` — Access message resources (images/files)
>
> **Enable the bot:**
> 1. Go to **"Add Features"** → enable **"Bot"**
> 2. Set the bot name and description
>
> **Publish the app:**
> 1. Go to **"Version Management & Release"** → create a version → submit for review
> 2. For personal/test use, the admin can approve it directly in the Feishu Admin Console

Then ask for **Domain** (optional):

> Default: `https://open.feishu.cn`
> Use `https://open.larksuite.com` for Lark (international version).
> Leave empty to use the default Feishu domain.

Then ask for **Allowed User IDs** (optional):

> Feishu user IDs (open_id format like `ou_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`).
> You can find them in the Feishu Admin Console under user profiles.
> Leave empty to allow all users who can message the bot.

**Step 3 — General settings**

Ask for default working directory, model, and mode with this guidance:

> **Working Directory:** The directory Claude Code will operate in when handling IM messages.
> Default: current directory (`$CWD`)
>
> **Model:** Which Claude model to use. Options:
> - `claude-sonnet-4-20250514` (default, fast and capable)
> - `claude-opus-4-6` (most capable, slower)
> - `claude-haiku-4-5-20251001` (fastest, for simple tasks)
>
> **Mode:** How Claude Code operates:
> - `code` (default) — Can read, write, and execute code
> - `plan` — Planning only, no file modifications
> - `ask` — Conversational, no tool use

**Step 4 — Write config and validate**

After collecting all input:
1. Only echo the last 4 characters of any token/secret in the confirmation summary
2. Use Bash to create directory structure: `mkdir -p ~/.claude-to-im/{data,logs,runtime,data/messages}`
3. Use Write to create `~/.claude-to-im/config.env` with all settings in KEY=VALUE format
4. Use Bash to set permissions: `chmod 600 ~/.claude-to-im/config.env`
5. Validate tokens:
   - Telegram: `curl -s "https://api.telegram.org/bot${TOKEN}/getMe"` — check for `"ok":true`
   - Feishu: `curl -s -X POST "${DOMAIN}/open-apis/auth/v3/tenant_access_token/internal" -H "Content-Type: application/json" -d '{"app_id":"...","app_secret":"..."}'` — check for `"code":0`
   - Discord: verify token matches format `[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+`
6. Report results with a summary table. If any validation fails, explain what might be wrong and how to fix it.

### `start`

Run: `bash "$SKILL_DIR/scripts/daemon.sh" start`

Show the output to the user. If it fails, suggest running `doctor`.

### `stop`

Run: `bash "$SKILL_DIR/scripts/daemon.sh" stop`

### `status`

Run: `bash "$SKILL_DIR/scripts/daemon.sh" status`

### `logs`

Extract optional line count N from arguments (default 50).
Run: `bash "$SKILL_DIR/scripts/daemon.sh" logs N`

### `reconfigure`

1. Read current config from `~/.claude-to-im/config.env`
2. Show current settings in a clear table format, with all secrets masked (only last 4 chars visible)
3. Use AskUserQuestion to ask what the user wants to change. Present options like:
   - Add/remove a channel
   - Update a token
   - Change working directory, model, or mode
   - Update allowed users/channels
4. When collecting new values, provide the same detailed guidance as in `setup` for the relevant field (e.g., if updating Discord token, show the full Discord token creation guide)
5. Update the config file atomically (write to tmp, rename)
6. Re-validate any changed tokens
7. Remind user: "Run `/claude-to-im stop` then `/claude-to-im start` to apply the changes."

### `doctor`

Run: `bash "$SKILL_DIR/scripts/doctor.sh"`

Show results and suggest fixes for any failures.

## Notes

- Always mask secrets in output (show only last 4 characters)
- If config.env doesn't exist and user runs start/status/logs, suggest running setup first
- The daemon runs as a background Node.js process managed by PID file
