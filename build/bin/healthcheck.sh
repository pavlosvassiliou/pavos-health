#!/bin/bash
cd /home/pavlos/pavos-health || exit 1
B=$(ls -1t build/logs/review-*.txt 2>/dev/null | head -1); B=$(basename "${B:-none}"); C=$(ls -1t build/logs/review-*.txt 2>/dev/null | head -1 | xargs -n1 basename 2>/dev/null)
echo "SYSTEM: review ${B:-none} · telegram $(systemctl is-active pavos-telegram) · health-telegram $(systemctl is-active pavos-health-telegram) · cron $(crontab -l 2>/dev/null | grep -c pavos)/4 · disk $(df -h / | awk 'NR==2{print $5}') used · unpushed $(git rev-list --count @{u}..HEAD 2>/dev/null || echo ?) · $(uptime -p)"
