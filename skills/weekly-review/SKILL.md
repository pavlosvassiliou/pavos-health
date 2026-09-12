---
name: weekly-review
description: Sunday 18:00 review of the week — data, adherence, what is booked, what needs him. Unattended. Graduation: three consecutive PASS against eval.md.
version: 0.1
status: draft — not yet run
---
# Weekly review

## Inputs
1. wiki/index.md, wiki/log.md (14 days), wiki/now.md, wiki/protocol.md and wiki/training.md if they exist.
2. data/*.csv — last 14 days, compare this week with last.
3. Gmail from senders in wiki/providers.md only, newer_than:7d, plus the Health label.
4. Calendar Health and Wellness, next 14 days.

## Do
1. Summarise the week from data: what was logged, what was not, trend versus last week. Numbers, not adjectives. If a CSV is empty, say so in one line and move on.
2. Adherence: what the protocol or plan said should happen versus what data and calendar show. Gaps are stated, not judged.
3. Logistics: anything booked, due, expiring, or needing a booking in the next 14 days.
4. Write the handoff: ~/pavos/handoffs/health-YYYY-MM-DD.md with logistics lines only (see CLAUDE.md wall). Copy to handoffs/. If nothing is due, write the file with the single line "nothing due".
5. Update wiki/now.md, append wiki/log.md and runs.md, git commit "review YYYY-MM-DD HHMM". Do not push.

## Output — plain text to Telegram, this shape:

    Week — <d Mon> to <d Mon>.

    DATA
    - <metric>: <this week> vs <last week> · <n> of 7 days logged
    - <training>: <sessions, minutes> vs last week

    ADHERENCE
    - <plan said X; data shows Y>

    NEEDS YOU (max 3)
    1. <one decision or one booking> [age]

    NEXT 14 DAYS
    - <booked> · <due>

    Anything to change for next week? One line is enough.

    REVIEW: <n> CSV rows read · <n> provider mails · handoff written (<n> lines) · <tool status>

## Rules
CLAUDE.md rules 1–5. Pre-graduation: zero sends. Never recommend changing prescribed treatment; surface the question. Never invent a number; an empty CSV is an empty line.
