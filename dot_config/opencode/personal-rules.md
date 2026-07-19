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
- **mise is the tool version manager** (`~/.config/mise/config.toml`). Prefer
  mise-managed runtimes (node, python, ruby, go, ...) over system/homebrew ones
  when installing or referencing tools.

## Neovim config portability (`~/.config/nvim`)

The nvim config must stay usable across machines/OSes with different toolchains:

- Never hardcode system-specific absolute paths (`/usr/bin/...`,
  `/opt/homebrew/...`) in plugin specs, build commands, or LSP/tool configs.
  Resolve via `PATH`, `vim.fn.stdpath`, `vim.fn.exepath`, or mason.
- Plugin `build` commands must not assume a specific python/compiler exists.
  Reference: `lua/plugins/nvim-dap-vscode-js.lua` uses `npm install
  --ignore-scripts` to skip test-only postinstalls (playwright) and native
  devDeps (node-gyp).
- Do not create `AGENTS.md`/agent docs inside `~/.config/nvim` — the dotfiles
  repo removes them via `.chezmoiremove`. Keep nvim-related rules here instead.
