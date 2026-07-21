# AGENTS.md — ~/.config/opencode

This repo IS the global OpenCode configuration, not a project. Every edit here
affects all OpenCode sessions on this machine. Load the built-in
`customize-opencode` skill before changing config shapes.

## Golden rules

- **Restart required**: `opencode.jsonc`, `tui.json`, agents, commands, skills,
  plugins, and themes are loaded once at startup. After any edit, tell the user
  to quit and restart OpenCode. No hot reload.
- **Strict validation**: OpenCode refuses to start on an invalid
  `opencode.jsonc` field. Check https://opencode.ai/config.json before writing
  fields you are unsure about. Keep the `$schema` line. JSONC comments are OK.
- **Broken startup**: fix config files directly in neovim. For plugin/skill
  breakage, boot with `OPENCODE_PURE=1` (skips external plugins) or
  `OPENCODE_DISABLE_EXTERNAL_SKILLS=1`, fix, restart without the flag.

## Layout (all auto-discovered — no registration in opencode.jsonc needed)

| Path | Contents |
| --- | --- |
| `opencode.jsonc` | global config: MCP servers, `small_model`, `instructions`, npm `plugin` array |
| `notification-ntfy.json` | ntfy.sh push-notification backend config (topic via `{env:NTFY_TOPIC}`) |
| `tui.json` | keybinds + theme |
| `agents/*.md` | subagents (bugbot, security-review, council-*) |
| `commands/*.md` | slash commands |
| `skills/<name>/SKILL.md` | skills paired with commands |
| `plugins/*.{ts,js}` | local plugins (rtk, notify); npm plugins live in the `plugin` array |
| `themes/*.json` | custom themes, referenced by name from `tui.json` |

- Prefer new files in these dirs over inline `agent:`/`command:` blocks in
  `opencode.jsonc`.
- Commands are thin wrappers: `commands/review.md` only says "load the `review`
  skill". To change behavior, edit `skills/<name>/SKILL.md`, not the command.

## Gotchas

- **MCP env vars**: local MCP servers here use `"environment"` (verified
  working with `linkedin`), NOT `"env"` as some docs/skills show. The
  `linkedin` server needs `uvx` on PATH; `sentry` is remote.
- **`plugins/rtk.ts` is a thin delegator**: rewrite rules live in the rtk Rust
  registry (`rtk rewrite`), never in this file. Requires the `rtk` binary on
  PATH (homebrew). `plugins/notify.js` fires macOS notifications on
  idle/error/permission-ask.
- **cursor-acp bridge (`@rama_nigg/open-cursor`)**: pinned version +
  source-audit date are recorded inline in `opencode.jsonc`; never bump
  without re-auditing the npm tarball. Provider model keys must be bare ids
  (`"auto"`, NOT `"cursor-acp/auto"`) or lookup fails with a misleading
  "Model not found … Did you mean" error. Auth comes from `cursor-agent
  login` (first-party token store), no `opencode auth login` needed. The
  proxy spawns per-process on 127.0.0.1:32124 (no persistent daemon). The
  model list is a synced snapshot (19 families, see date in the config
  comment); to refresh, run `open-cursor sync-models --variants --compact`
  with `OPENCODE_CONFIG` pointed at a THROWAWAY json file, then hand-merge
  the `models` map — running it against this JSONC directly rewrites it as
  plain JSON and strips comments. Variant selection (fast/thinking/effort)
  happens in the TUI via `variant_cycle` after picking the family, or the
  `variant` field in an agent/command definition — there is NO
  `--model provider/model/variant` CLI syntax (opencode 1.18.3 rejects it
  with a cryptic "Unexpected server error"). Bridge env toggles (set in
  `~/.zshrc`): `CURSOR_ACP_BRIDGE_JSON=off` disables the bridge-json prompt
  shim (its "SYSTEM: opencode bridge" preamble makes models complain about
  prompt injection on every message); `CURSOR_ACP_WORKSPACE` pins the
  workspace path Cursor attributes usage to (`oc-lms` alias pins the
  principal work repo); `CURSOR_ACP_SESSION_RESUME=true` resumes the
  underlying Cursor chat across opencode restarts. Env only reaches the
  process that OWNS the :32124 proxy — restart stale opencode processes
  after changing these. Caveat: with the Option C manual provider block ALL
  bridge traffic goes to whatever opencode process owns :32124 first, so
  attribution follows the proxy owner's spawn directory unless the env pin
  is set on that process.
- **`package.json` + `node_modules` exist only for `@opencode-ai/plugin`
  types** (editor IntelliSense when writing plugins). npm plugins from the
  `plugin` array install to `~/.cache/opencode/node_modules/` instead.
  `node_modules`, `package-lock.json`, `bun.lock`, and `.gitignore` here are
  chezmoi-ignored (see `.chezmoiignore.tmpl` in the dotfiles repo); run
  `npm install` after a fresh machine bootstrap.
- **Versioned via chezmoi, not local git.** This whole tree is managed by
  chezmoi (source repo: `~/.local/share/chezmoi`, remote: dotfiles). Any
  change here MUST be tracked and shipped with this workflow:
  1. Edit files in `~/.config/opencode` (the target dir).
  2. `chezmoi re-add ~/.config/opencode` for modified files; `chezmoi add` for
     new files (skip machine-generated artifacts — chezmoiignore covers them).
  3. In the source repo: branch off `origin/main` (`git checkout -b
     feat/<topic> origin/main` after a fetch; never branch off whatever
     feature branch happens to be checked out).
  4. Always run pre-commit before committing: `uvx pre-commit run --files
     <changed>` (`pre-commit` is not installed globally; `uvx` is). The repo
     runs gitleaks/trivy/trufflehog — no secrets, tokens, or plaintext topics
     in committed files.
  5. Conventional commit, push, `gh pr create --base main`.
- **External skills**: `~/.agents/skills/` (computer-use, council, find-skills,
  orca-cli, orchestration) auto-load but live OUTSIDE this repo — edit them in
  place there, never copy them in here.

## Instruction chain (keep these scopes separate)

1. This `AGENTS.md` — only active when a session's cwd is inside this
   directory (i.e. when managing the config itself).
2. `personal-rules.md` — loaded for EVERY session via `instructions` in
   `opencode.jsonc` (no AI attribution in commits/PRs, conventional commits).
3. `~/.claude/CLAUDE.md` → `@RTK.md` — loaded via Claude Code compatibility;
   RTK token-saver rules. The `rtk` plugin enforces them automatically.

Keep global personal rules in `personal-rules.md`; keep config-management
guidance here. Do not duplicate one into the other.

## Conventions

- User is a neovim user who wants keybind-driven workflows. TUI leader is
  `ctrl+x`; follow the existing leader-based style when adding keybinds in
  `tui.json`. Current theme: `tokyonight-storm`.
- `small_model: google/gemini-3.5-flash` handles housekeeping (title/summary).
  Subagents pin their own models in frontmatter (e.g. bugbot →
  `google/gemini-3.1-pro-preview`); pick a deliberate per-agent model when
  adding new agents instead of inheriting the session model.
- The `council-*` agents are a deliberately model-diverse set (different labs
  per role) — extend the set rather than collapsing them into one agent.
