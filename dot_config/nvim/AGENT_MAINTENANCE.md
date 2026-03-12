# Maintenance Agent - Plugin & Config Stability

**Role**: Keep plugins updated, dependencies stable, and configuration working smoothly.

## Pre-Flight Checklist
Before any maintenance work:
1. Read `AGENTS.md` for code style and patterns
2. Check git status: `git status` to see current state
3. Create a backup branch: `git checkout -b maintenance/$(date +%Y%m%d)`
4. Verify Neovim is working: `nvim --headless -c "checkhealth" -c "quit"`

## Core Responsibilities

### 1. Plugin Updates
**Check for updates:**
```bash
# Inside nvim
:Lazy sync          # Update all plugins
:Lazy check         # Check for plugin updates without installing
:Lazy profile       # Check startup time impact
```

**After updating plugins:**
- [ ] Test Neovim startup: `nvim`
- [ ] Check for errors in `:Lazy` dashboard
- [ ] Run `:checkhealth` to identify issues
- [ ] Test LSP: Open a file and verify `gd`, `K`, `<leader>la` work
- [ ] Test completion: Type in insert mode, verify blink.cmp shows suggestions
- [ ] Test formatters: Save a file, verify formatting works
- [ ] Test Git integrations: `:Neogit` and gitsigns work

**If issues occur:**
1. Check `lazy-lock.json` - revert problematic plugin versions
2. Read plugin's CHANGELOG/breaking changes
3. Update config in `lua/plugins/*.lua` or `lua/configs/*.lua` as needed
4. Check for deprecated APIs: `vim.lsp.buf.*`, `vim.diagnostic.*`

### 2. Dependency Management
**Mason packages** (LSPs, formatters, linters):
```vim
:Mason                      " Check installed packages
:MasonInstallFromList       " Install from chadrc.lua list
:MasonUpdate                " Update all Mason packages
```

**Update Mason package list in `lua/chadrc.lua`:**
- Add new packages to `M.mason.pkgs` table
- Remove unused packages
- Keep formatters in sync with `lua/configs/conform.lua`
- Keep linters in sync with `lua/configs/lint.lua`
- Keep LSPs in sync with `lua/configs/lspconfig.lua`

**LuaSnip snippets:**
- Snippets auto-load from `./snippets/` directory
- Update snippet packages in plugin dependencies if needed

### 3. Breaking Changes & Deprecations
**Common Neovim 0.10+ breaking changes:**
- `vim.lsp.buf.formatting()` → use conform.nvim
- `vim.lsp.buf.range_formatting()` → use conform.nvim
- Check plugin deprecation notices in `:Lazy` log
- Update `on_attach` functions if LSP API changes

**Plugin-specific migrations:**
- **blink.cmp**: Active (nvim-cmp is disabled)
- **rustaceanvim**: Replaces rust-tools.nvim
- **markdown_oxide**: Replaces marksman for Obsidian notes

### 4. Configuration Stability
**Run these checks after any changes:**
```bash
# Format check
stylua --check .

# Lint check
luacheck lua/ --globals vim

# Config syntax check
nvim --headless -c "lua vim.cmd('quit')"

# Full health check
nvim --headless -c "checkhealth" -c "quit"
```

**Test critical workflows:**
1. **LSP**: Open Lua/Go/Rust/Ruby file → test completions, go-to-def, diagnostics
2. **Telescope**: `<leader>ff` → find files works
3. **Git**: `<leader>gg` → lazygit opens
4. **Formatting**: Edit file → save → auto-format works
5. **Snippets**: Insert mode → `<Tab>` → snippet expands

### 5. Performance Monitoring
```vim
:Lazy profile               " Check plugin load times
```

**Performance targets:**
- Startup time: < 50ms (with plugins lazy-loaded)
- LSP attach: < 200ms
- Completion popup: < 50ms

**If performance degrades:**
- Check `lua/configs/lazy.lua` - verify `defaults = { lazy = true }`
- Review plugin `event` triggers - defer non-critical plugins
- Use `:Lazy profile` to identify slow plugins
- Consider disabling heavy plugins (image.nvim, render-markdown, etc.)

### 6. Dependency Conflicts
**Common conflict sources:**
- Multiple completion engines (only blink.cmp should be enabled)
- Overlapping LSP configurations
- Conflicting keymaps (check `lua/mappings.lua`)
- Mason package version mismatches

**Resolution steps:**
1. Check `:Lazy` for plugin conflicts
2. Verify only one plugin provides each feature
3. Use `pcall()` for optional dependencies
4. Check `enabled = false` in disabled plugins

### 7. Update Workflow Template
When performing maintenance updates:

```bash
# 1. Backup
git checkout -b maintenance/YYYYMMDD
git add -A && git commit -m "chore: backup before maintenance"

# 2. Update plugins
nvim
# Inside nvim: :Lazy sync

# 3. Update Mason packages
# Inside nvim: :MasonUpdate

# 4. Test
nvim --headless -c "checkhealth" -c "quit"
stylua --check .
luacheck lua/ --globals vim

# 5. Manual testing (open nvim and test workflows)

# 6. Commit
git add lazy-lock.json
git commit -m "chore: update plugin lockfile"

# 7. Document changes
# Add notes about breaking changes, removed plugins, etc.
```

## Emergency Rollback
If something breaks badly:
```bash
# Restore previous plugin versions
git checkout HEAD~1 lazy-lock.json
nvim
# Inside nvim: :Lazy restore
```

## Maintenance Schedule
- **Weekly**: Check for plugin updates with `:Lazy check`
- **Monthly**: Full update cycle with testing
- **Quarterly**: Review disabled plugins, remove unused configs
- **Yearly**: Major version updates (Neovim, NvChad base)

## Health Check Command
Create a comprehensive health check:
```vim
:checkhealth
:Lazy check
:Mason
:LspInfo
:ConformInfo
```

## Documentation
After maintenance, update:
- `lazy-lock.json` (automatic)
- Add notes to git commit about breaking changes
- Update `README.md` if plugin list changes significantly
