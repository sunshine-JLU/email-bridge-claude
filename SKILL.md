# Email Bridge Skill

Communicate with Claude Code via email — send task results, receive and execute instructions from email.

## Setup

1. Copy `email-config.example.json` to `email-config.json` and fill in credentials
2. Copy all files into your Claude Code project
3. Start the background poller

## Configuration (`email-config.json`)

```json
{
  "sender": "your_email@163.com",
  "receiver": "your_receiver@qq.com",
  "smtp_server": "smtp.163.com",
  "smtp_port": 465,
  "smtp_auth": "YOUR_SMTP_AUTH_CODE",
  "pop_server": "pop.163.com",
  "pop_port": 995
}
```

To get an SMTP/POP3 auth code for 163.com:
- Settings → POP3/SMTP/IMAP → Enable SMTP and POP3
- Copy the generated authorization code

## Commands

```bash
# Send an email
python3 email-bridge.py send "<subject>" "<body>"

# Check for new emails
python3 email-bridge.py check [limit]
```

## Architecture (Zero-Waste Auto-Polling)

To avoid wasting LLM tokens on empty mailbox checks, use a two-tier architecture:

```
Background Bash Loop (zero LLM cost)
  │  every 3 min: POP3 check → new emails? → write to /tmp/email-pending-queue.txt
  │
Cron (every 10-15 min)
  │  queue empty? → reply "." (1 token)
  │  queue has mail? → read, execute, reply via email, clear queue
```

### 1. Start the background poller

```bash
chmod +x email-poll-loop.sh
nohup ./email-poll-loop.sh &>/dev/null &
```

This loops silently — POP3 check every 3 minutes, writes new user emails to `/tmp/email-pending-queue.txt`. No LLM interaction at all.

### 2. Set up the cron in Claude Code

```
/loop 13m check /tmp/email-pending-queue.txt:
  if empty, reply ".". If has mail, read instructions,
  execute, reply via python3 email-bridge.py send,
  then clear the queue.
```

Or use CronCreate with:
```
*/13 * * * *
prompt: check /tmp/email-pending-queue.txt — if empty reply ".",
if has content, process instructions, email results via
email-bridge.py send, then truncate the queue.
```

## When Claude Code Uses Email

**Send notifications** — long-running tasks (>2 min), or when user says "notify me when done".

**Check inbox** — automatic via the background poller + cron setup above.

## Email Command Protocol

1. Background poller detects new email → writes to queue
2. Cron fires → Claude reads queue file
3. Execute the email body as a command
4. Reply via email with results
5. Clear the queue file

## Supported Providers

| Provider | SMTP Server | POP3 Server |
|----------|-------------|-------------|
| 163.com  | smtp.163.com:465 | pop.163.com:995 |
| QQ Mail  | smtp.qq.com:465 | pop.qq.com:995 |
| Gmail    | smtp.gmail.com:465 | pop.gmail.com:995 |

## File Structure

```
email-bridge/
├── email-bridge.py              # Send/check emails
├── email-poll-loop.sh           # Background silent poller
├── SKILL.md                     # This file
├── email-config.example.json    # Config template
├── .gitignore
├── LICENSE
└── README.md
```

## Security

- `email-config.json` is gitignored — never commit auth codes
- `.email-seen.json` tracks processed email UIDs locally
- Auth codes stay in local config only

## License

MIT
