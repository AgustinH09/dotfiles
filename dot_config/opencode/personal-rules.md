# Personal rules (ported from Cursor CLI config)

## Git attribution

Ported from Cursor `cli-config.json` (`attribution.attributeCommitsToAgent: false`,
`attributePRsToAgent: false`):

- Never add `Co-authored-by`, `Generated-with`, `Signed-off-by`, or any other
  agent/AI attribution trailers to commit messages.
- Never mention an AI agent in PR titles, bodies, or review comments unless the
  user explicitly asks.

## Commits

- Use conventional commit messages (`feat: ...`, `fix: ...`, `chore: ...`).
- Keep commits focused; stage only files relevant to the change.

## Tooling preferences

- RTK token-saver instructions come from `~/.claude/CLAUDE.md` + `~/.claude/RTK.md`
  (loaded via OpenCode's Claude Code compatibility). The `rtk` OpenCode plugin
  rewrites bash commands automatically, exactly like the Cursor `rtk hook cursor`
  preToolUse hook did.
