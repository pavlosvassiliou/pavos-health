#!/bin/bash
set -u
export HOME=/home/pavlos PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin" TZ=Europe/London
source "$HOME/.pavos-health.env"
cd "$HOME/pavos-health" || exit 1
TODAY=$(date +%F); STAMP=$(date '+%F %H%M'); LOG="build/logs/review-$(date +%F-%H%M).log"
tg() { curl -s -g -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" -d chat_id="$TELEGRAM_CHAT_ID" --data-urlencode text="$1" >/dev/null; }
git pull -q --ff-only 2>>"$LOG" || true
ALLOW="Read,Glob,Grep,Edit,Write,Bash(git add:*),Bash(git commit:*),Bash(date:*),Bash(ls:*),Bash(cat:*),Bash(cp:*),\
mcp__claude_ai_Gmail__search_threads,mcp__claude_ai_Gmail__get_thread,mcp__claude_ai_Gmail__get_message,mcp__claude_ai_Gmail__list_labels,\
mcp__claude_ai_Google_Calendar__list_calendars,mcp__claude_ai_Google_Calendar__list_events,mcp__claude_ai_Google_Calendar__get_event"
DENY="mcp__claude_ai_Gmail__send_message,mcp__claude_ai_Gmail__reply,mcp__claude_ai_Gmail__forward,mcp__claude_ai_Gmail__create_draft,mcp__claude_ai_Gmail__update_draft,mcp__claude_ai_Gmail__trash_message,mcp__claude_ai_Gmail__trash_thread,\
mcp__claude_ai_Google_Calendar__create_event,mcp__claude_ai_Google_Calendar__update_event,mcp__claude_ai_Google_Calendar__delete_event,mcp__claude_ai_Google_Calendar__respond_to_event,\
mcp__claude_ai_Google_Drive__create_file,mcp__claude_ai_Google_Drive__update_file,mcp__claude_ai_Google_Drive__trash_file,mcp__claude_ai_Google_Drive__share_file,Bash(git push:*),Bash(curl:*),Bash(rm:*)"
PROMPT="Today is $(date '+%A %d %B %Y'), $(date +%H:%M) Europe/London. Execute skills/weekly-review/SKILL.md now, unattended, following CLAUDE.md. Status is draft: ZERO sends. Write the review text (exactly the Output shape) to build/logs/review-$STAMP.txt, write the handoff to /home/pavlos/pavos/handoffs/health-$TODAY.md and copy it to handoffs/, update wiki/now.md and wiki/log.md, append a row to skills/weekly-review/runs.md, then git add -A and git commit -m 'review $STAMP'. Do not push. Final reply: exactly one line, the path of the review text file."
flock -w 900 "$HOME/.lock-pavos-health" timeout 420 claude -p "$PROMPT" --model claude-opus-5 --allowedTools "$ALLOW" --disallowedTools "$DENY" --permission-mode acceptEdits --max-turns 50 --add-dir /home/pavlos/pavos/handoffs --output-format json >"$LOG.json" 2>>"$LOG"; RC=$?; python3 /home/pavlos/pavos/build/bin/telemetry.py "$LOG.json" health-review /home/pavlos/pavos-health >"$LOG.out"
OUT=$(ls -1 build/logs/review-"$TODAY"*.txt 2>/dev/null | tail -1)
if [ -n "$OUT" ] && [ -s "$OUT" ]; then
  git push -q 2>>"$LOG" || true
  ( cd "$HOME/pavos" && flock -w 900 "$HOME/.lock-pavos" sh -c 'git add handoffs && git commit -qm "health handoff $TODAY" && git push -q' ) 2>>"$LOG" || true
  split -b 3900 -d "$OUT" "$LOG.part."; for p in "$LOG".part.*; do tg "$(cat "$p")"; done; rm -f "$LOG".part.*
  echo "$(date '+%F %T') OK rc=$RC out=$OUT" >> build/logs/runs.log
else
  tg "PavOS Health: weekly review FAILED $(date '+%H:%M') (rc=$RC). See build/logs/ on the VM."
  echo "$(date '+%F %T') FAIL rc=$RC" >> build/logs/runs.log
fi
