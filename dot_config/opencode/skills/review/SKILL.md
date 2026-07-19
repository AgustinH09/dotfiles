---
name: review
description: Review code changes with the bugbot or security-review subagent. Use when the user asks to run /review or to review the current changes without specifying a review type.
---

# Review

Ask the user which review to run with the `question` tool. If the question tool is not available, ask the user directly. Provide exactly one single-select question with two options:

- `bugbot`: Bugbot (`/review-bugbot`)
- `security`: Security Review (`/review-security`)

After the user chooses, run the matching review once:

- Bugbot: follow the `review-bugbot` skill instructions.
- Security Review: follow the `review-security` skill instructions.
