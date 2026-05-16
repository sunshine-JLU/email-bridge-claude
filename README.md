# Email Bridge for Claude Code

> Control Claude Code via email — send instructions, receive results. Ideal for long-running tasks and remote work.

## How It Works

```
You (QQ/Gmail) ──email──> Sender (163) ──POP3──> Claude Code
                                                  │
                                          reads + executes
                                                  │
You (QQ/Gmail) <──email── Sender (163) <──SMTP────┘
```

- **Send**: Claude Code uses SMTP to send emails (task results, notifications)
- **Receive**: Claude Code uses POP3 to check inbox for new instructions
- **Auto-polling**: Set up a `/loop` and Claude Code checks email every few minutes

## Quick Start

### 1. Enable SMTP & POP3 on your email

For **163.com** (recommended as sender):
- Go to mail.163.com → Settings → POP3/SMTP/IMAP
- Enable **SMTP** and **POP3** services
- Copy the authorization codes

For **QQ Mail** (recommended as receiver):
- Go to mail.qq.com → Settings → Account → POP3/SMTP
- Enable SMTP and POP3 if you plan to use QQ as sender

### 2. Configure

```bash
git clone https://github.com/YOUR_USER/email-bridge-claude.git
cd email-bridge-claude
cp email-config.example.json email-config.json
# Edit email-config.json with your credentials
```

### 3. Install in Claude Code

Copy these two files into your Claude Code project:

```bash
cp email-bridge.py SKILL.md /path/to/your-project/.claude/skills/
cp email-config.json /path/to/your-project/.claude/
```

### 4. Start using

In Claude Code:
```
/loop 3m check email: run `python3 email-bridge.py check 3`,
if new emails from receiver, execute instructions and reply via send.
```

Then send an email to your sender address — Claude Code will pick it up and respond.

## Commands

```bash
# Send email
python3 email-bridge.py send "Subject" "Body text here"

# Check inbox for new emails
python3 email-bridge.py check 5    # shows last 5 new emails
```

## Supported Providers

| Provider | SMTP (SSL) | POP3 (SSL) |
|----------|------------|------------|
| 163.com  | smtp.163.com:465 | pop.163.com:995 |
| QQ Mail  | smtp.qq.com:465 | pop.qq.com:995 |
| Gmail    | smtp.gmail.com:465 | pop.gmail.com:995 |

Other providers work too — just update `smtp_server`, `smtp_port`, `pop_server`, `pop_port` in config.

## File Structure

```
email-bridge/
├── email-bridge.py              # Main script
├── SKILL.md                     # Claude Code skill definition
├── email-config.example.json    # Config template
├── .gitignore                   # Excludes real configs
├── LICENSE
└── README.md                    # This file
```

## Security

- `email-config.json` is gitignored — never commit your auth codes
- `.email-seen.json` tracks processed emails locally
- Auth codes are only stored in the local config file

## License

MIT © 2026
