#!/bin/bash
# Silent background email poller. Checks POP3 every 3 min.
# Writes new user emails to queue file — zero LLM cost.
# Auto-expires after 24 hours. Run with: nohup ./email-poll-loop.sh &>/dev/null &

QUEUE_FILE="${EMAIL_QUEUE_FILE:-/tmp/email-pending-queue.txt}"
LOCK_FILE="/tmp/email-poll.lock"
BRIDGE="$(cd "$(dirname "$0")" && pwd)/email-bridge.py"
SYS_SENDERS="service.netease.com|club@service.netease.com|safe@service.netease.com"

# Read receiver from config to filter correctly
RECEIVER=$(python3 -c "import json; print(json.load(open('$(dirname "$0")/email-config.json'))['receiver'])" 2>/dev/null || echo "")

exec 200>"$LOCK_FILE"
flock -n 200 || exit 0

END_TIME=$(($(date +%s) + 86400))

while [ $(date +%s) -lt $END_TIME ]; do
    OUTPUT=$($BRIDGE check 3 2>/dev/null)
    if echo "$OUTPUT" | grep -q "^New:"; then
        HAS_USER=$(echo "$OUTPUT" | grep -vE "$SYS_SENDERS" | grep "$RECEIVER")
        if [ -n "$HAS_USER" ]; then
            echo "=== $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$QUEUE_FILE"
            echo "$OUTPUT" >> "$QUEUE_FILE"
        fi
    fi
    sleep 180
done

rm -f "$LOCK_FILE"
