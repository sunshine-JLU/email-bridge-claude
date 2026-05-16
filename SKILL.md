# Email Bridge Skill

Communicate with Claude Code via email — send task results, receive and execute instructions from email.

## Setup

1. Copy `email-config.example.json` to `email-config.json`
2. Fill in your email credentials (see Configuration)
3. Copy `email-bridge.py` and `SKILL.md` into your Claude Code project

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

Other email providers (QQ, Gmail, etc.) — just update the server/port fields.

## Commands

```bash
# Send an email
python3 email-bridge.py send "<subject>" "<body>"

# Check for new emails
python3 email-bridge.py check [limit]
```

## When Claude Code Uses Email

**Send notifications** — long-running tasks (>2 min), or when the user says "notify me when done".

**Check inbox** — user says "check my email", or via a recurring cron/loop. Claude reads the email body as a command, executes it, and replies by email with the result.

## Email Command Protocol

1. Check inbox for new emails → `python3 email-bridge.py check`
2. For each new email from the receiver address:
   - Read body as command/instruction
   - Execute the command
   - Send result back via `python3 email-bridge.py send "Re: ..." "..."`
3. Emails are auto-tracked as seen via `.email-seen.json` (UID tracking)

## Auto-Polling (in Claude Code)

To have Claude Code automatically check for email commands, set up a recurring loop:

```
/loop 3m check email: run `python3 email-bridge.py check 3`, if new emails from
receiver, execute instructions and reply via send. Ignore system/notification emails.
```

This makes Claude Code fully controllable via email without manual prompting.

## Supported Providers

| Provider | SMTP Server | POP3 Server |
|----------|-------------|-------------|
| 163.com  | smtp.163.com:465 | pop.163.com:995 |
| QQ Mail  | smtp.qq.com:465 | pop.qq.com:995 |
| Gmail    | smtp.gmail.com:465 | pop.gmail.com:995 |

## Security

- Never commit `email-config.json` — it's in `.gitignore`
- Store auth codes only in the local config file
- The `.email-seen.json` file tracks processed email UIDs locally

## License

MIT
