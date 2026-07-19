---
name: loop
description: >-
  Run a prompt or task repeatedly on a fixed or self-paced interval (e.g.
  /loop 5m check deploy status). Adapted for OpenCode: runs as a foreground
  loop inside the session; the user can interrupt at any time.
metadata:
  origin: cursor
---

# Loop

Accept `/loop [interval] <prompt>`.

- Leading interval: `5m /foo`, `30s check status`, `2h run report`.
- Trailing interval: `check deploy every 5m`, `run tests every 10 minutes`.
- No interval: dynamic mode; you choose the next delay after each run.
- Empty prompt: show `Usage: /loop [interval] <prompt>`.

Use intervals like `30s`, `5m`, `2h`, `1d`. Convert unit words to short units.

## OpenCode execution model

OpenCode has no background wake-up mechanism, so the loop runs **in the foreground of this session**:

1. Run the prompt once immediately.
2. `sleep <seconds>` via the bash tool.
3. Run the prompt again, and repeat until the user interrupts or asks to stop, or a natural stop condition is met (e.g. CI green, deploy finished — say you're stopping and why).

Do NOT launch detached/background shell loops (`nohup`, `&`, disown): their results can never reach this session and they strand processes on the user's machine.

## Fixed schedule

- Run the prompt now, report briefly what changed (first run: the baseline).
- Sleep the full interval, then re-run. On each tick give a short diff-style update — what changed since the last tick — instead of repeating the full previous report.
- Before starting, confirm: the interval, that the prompt already ran once, and that the loop continues until interrupted.

## Dynamic schedule (self-paced)

1. Run the prompt now.
2. Decide what makes the next run worth it — a passage of time or an observable event (a git ref advancing, a log line appearing, a CI check completing).
3. If gated on an event, poll for the event inside the sleep step (short bash loop that exits when the event fires or a long timeout elapses), then act immediately when it fires.
4. State up front: that you're self-pacing, what event or delay you picked, and that the prompt already ran.

## Guidance

- Cap runs at a sensible count when the loop would otherwise be infinite (e.g. 100 ticks) and tell the user the cap.
- Keep each tick cheap: avoid noisy commands, reuse prior results, don't re-read the world when a targeted check suffices.
- If the task errors, don't spin hot — back off (double the sleep, up to the original interval cap) and mention it.
- When the user says stop, stop after the current tick and summarize what the loop accomplished.
