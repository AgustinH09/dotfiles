# Agent Guidelines for NvChad Config

## Build/Lint/Test Commands
- **Format Lua**: `stylua .` (uses `.stylua.toml`: 120 column width, 2 spaces, Unix line endings, no call parentheses)
- **Lint Lua**: `luacheck lua/ --globals vim` (configured in `lua/configs/lint.lua`)
- **Manual lint**: Open nvim and run `:Lint`
- **Check config**: `nvim --headless -c "checkhealth" -c "quit"` or just start `nvim`
- **No test suite**: This is a personal config; validation is done by loading Neovim

## Code Style Guidelines
- **Language**: Lua (5.1), following NvChad conventions
- **Indentation**: 2 spaces, Unix line endings, 120 char column width
- **Quotes**: Auto-prefer double quotes
- **Call style**: No parentheses for function calls when possible (e.g., `require "module"` not `require("module")`)
- **Imports**: Use `require "module"` at top; avoid circular dependencies; lazy-load plugins via `event`, `cmd`, `keys`, `ft`
- **Structure**: Plugin specs in `lua/plugins/*.lua`, configs in `lua/configs/*.lua`, keymaps in `lua/mappings.lua`
- **Naming**: snake_case for files/functions, kebab-case for plugin file names
- **Types**: Use LSP hints via `lua_ls`; prefer explicit type comments for complex functions
- **Error handling**: Use `pcall` for operations that may fail (e.g., loading optional modules)
- **Comments**: Prefer section headers with `----- SECTION -----` style; inline comments for non-obvious logic
- **Plugin format**: Follow lazy.nvim spec format with `dependencies`, `event`, `config`, `opts` keys
- **Config files**: Return tables from config files; use functions for dynamic setup
- **Keymaps**: Use helper function `M()` wrapper in mappings.lua; include `desc` for discoverability

## Important Patterns
- **Async operations**: Use `vim.defer_fn()` or `vim.schedule()` for deferred/async work
- **Autocmds**: Use `vim.api.nvim_create_autocmd()` and `vim.api.nvim_create_augroup()` (not `vim.cmd`)
- **Opts pattern**: Use `opts = function() ... end` when config needs dynamic values or extends defaults
- **Table merging**: Use `vim.tbl_extend("force", ...)` or `vim.tbl_deep_extend("force", ...)` for config merging
- **Mason packages**: Add new tools to `lua/chadrc.lua` in `M.mason.pkgs` table
- **Completion**: Uses `blink.cmp` (enabled) not `nvim-cmp` (disabled); check `lua/plugins/blink-cmp.lua`
- **LSP setup**: Config in `lua/configs/lspconfig.lua`; use `on_attach` wrapper to remove conflicting NvChad keymaps
- **Disabled plugins**: Many plugins have `enabled = false`; check existing plugin files before adding duplicates
- **User commands**: Define in `lua/cmds.lua` using `vim.api.nvim_create_user_command()` with `desc` field
