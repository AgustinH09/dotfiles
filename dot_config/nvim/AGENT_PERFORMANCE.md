# Performance Optimization Agent - NvChad Config

**Role**: Specialist agent for analyzing, profiling, and optimizing Neovim startup time and runtime performance.

---

## Prerequisites

Before performing any performance tasks, review these resources:
- `lua/configs/lazy.lua` - Lazy loading configuration (sets all plugins to `lazy = true` by default)
- `lua/plugins/` - Plugin specifications with lazy-loading strategies
- Base guidelines in `AGENTS.md`

---

## Performance Targets

### Startup Time Goals
- **Cold start** (first launch): < 100ms
- **Warm start** (subsequent launches): < 50ms
- **Plugin load time** (total): < 200ms
- **LSP attach time**: < 500ms

### Runtime Goals
- **Key input latency**: < 10ms
- **Scroll performance**: 60fps minimum
- **LSP response**: < 100ms for small files, < 500ms for large files
- **Completion popup**: < 50ms

---

## Performance Analysis Tools

### Built-in Profilers

#### Lazy.nvim Profile
**Command**: `:Lazy profile`

**Shows**:
- Plugin load time
- Startup sequence
- Longest loading plugins
- Load triggers (event, cmd, keys, ft)

**Usage**:
```vim
# Open Neovim
:Lazy profile
# Sort by time (press 't')
# Look for plugins > 10ms
```

#### Neovim Built-in Profiler
**Command**: `nvim --startuptime startup.log`

**Shows**:
- Detailed startup sequence
- Time for each sourced file
- Total startup time

**Usage**:
```bash
nvim --startuptime startup.log
# Analyze log
nvim startup.log
# Sort by time: /^\s*\d\+\.\d\+ to find largest numbers
```

#### Lua Profiler
**For runtime performance**:
```lua
-- Add to code to profile
local start = vim.loop.hrtime()
-- Code to profile
local elapsed = (vim.loop.hrtime() - start) / 1e6
print(string.format("Operation took %.2fms", elapsed))
```

---

## Common Performance Issues

### Issue 1: Slow Startup (> 100ms)

#### Diagnosis
```bash
nvim --startuptime startup.log -c "quit"
# Check total time at end of log
```

**Look for**:
- Plugins loading on startup (should be lazy-loaded)
- Heavy autocmds
- Large treesitter parsers compiling

#### Solutions

**A. Ensure plugins are lazy-loaded**

Check `lua/configs/lazy.lua:7`:
```lua
defaults = { lazy = true }
```

This makes ALL plugins lazy by default. Override only when needed:
```lua
-- BAD: Loads on startup
{ "plugin/name" }

-- GOOD: Loads on event
{ "plugin/name", event = "VeryLazy" }

-- GOOD: Loads on command
{ "plugin/name", cmd = "PluginCommand" }

-- GOOD: Loads on keymap
{ "plugin/name", keys = { "<leader>x" } }

-- GOOD: Loads for filetype
{ "plugin/name", ft = "lua" }
```

**B. Defer heavy operations**

```lua
-- BAD: Runs immediately
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    heavy_operation()
  end
})

-- GOOD: Defers 100ms
vim.defer_fn(function()
  heavy_operation()
end, 100)
```

**C. Lazy-load LSP servers**

In `lua/configs/lspconfig.lua`, LSP servers attach on `LspAttach` event, which is already optimized. Don't change unless you know what you're doing.

**D. Reduce treesitter parsers**

Edit `lua/configs/treesitter.lua:3-31` - only include languages you use:
```lua
ensure_installed = {
  -- Only install what you actually use
  "lua", "vim", "vimdoc",
  -- Remove languages you don't use
}
```

### Issue 2: Slow LSP Response

#### Diagnosis
```vim
:LspInfo  # Check if multiple servers attached
:lua print(vim.inspect(vim.lsp.get_active_clients()))
```

**Look for**:
- Multiple LSP servers for same language
- LSP hanging on large files
- Root directory detection issues

#### Solutions

**A. Disable conflicting LSP servers**

In `lua/configs/mason-lspconfig.lua:48`, comment out unused servers:
```lua
local servers = {
  -- "lua_ls",  # Disable if not using Lua
  -- "ts_ls",   # Disable if only using Deno
}
```

**B. Optimize LSP for large files**

Add to `lua/configs/lspconfig.lua`:
```lua
-- Before on_attach function
local function on_attach(client, bufnr)
  -- Disable semantic tokens for large files
  if vim.api.nvim_buf_line_count(bufnr) > 10000 then
    client.server_capabilities.semanticTokensProvider = nil
  end
  
  -- Your existing on_attach logic
end
```

**C. Debounce diagnostics**

```lua
vim.diagnostic.config({
  update_in_insert = false,  -- Don't update in insert mode
  virtual_text = { spacing = 4, prefix = "●" },
})
```

### Issue 3: Slow Completion Popup

#### Diagnosis
Check `lua/plugins/blink-cmp.lua` config (this config uses `blink.cmp`, NOT `nvim-cmp`).

**Look for**:
- Too many completion sources
- LSP snippets expanding slowly
- Large completion menus

#### Solutions

**A. Limit completion sources**

In `lua/plugins/blink-cmp.lua`, reduce sources:
```lua
sources = {
  default = { 'lsp', 'path', 'snippets' },  -- Remove 'buffer' for speed
}
```

**B. Reduce max items**

```lua
menu = {
  max_items = 50,  -- Default 200, reduce for speed
}
```

**C. Disable slow sources in large files**

```lua
autocmd BufEnter * lua
  if vim.api.nvim_buf_line_count(0) > 5000 then
    require('blink-cmp').setup({ sources = { default = {'lsp'} } })
  end
```

### Issue 4: Slow Scrolling/Rendering

#### Diagnosis
```vim
:set regexpengine?  # Should be 0 (auto)
:set lazyredraw?    # Should be set
```

**Look for**:
- Treesitter highlighting lag
- Virtual text plugins (dap-virtual-text, indent-blankline)
- Slow statusline updates

#### Solutions

**A. Optimize treesitter**

In `lua/configs/treesitter.lua`:
```lua
highlight = {
  enable = true,
  disable = function(lang, buf)
    local max_filesize = 100 * 1024  -- 100 KB
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
    if ok and stats and stats.size > max_filesize then
      return true
    end
  end,
}
```

**B. Disable virtual text in large files**

```lua
-- In autocmds.lua
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    if vim.api.nvim_buf_line_count(0) > 1000 then
      vim.diagnostic.config({ virtual_text = false })
    end
  end
})
```

**C. Optimize indent-blankline**

In `lua/plugins/indent-blankline.lua`:
```lua
config = function()
  require("ibl").setup({
    debounce = 200,  -- Increase from default 100ms
    viewport_buffer = { min = 30, max = 100 },  -- Reduce rendered lines
  })
end
```

### Issue 5: Memory Leaks

#### Diagnosis
```vim
:lua print(collectgarbage("count"))  # Memory in KB
```

Run multiple times - if increasing rapidly, you have a leak.

**Look for**:
- Autocmds not cleaning up
- LSP clients not detaching
- Timers not stopping

#### Solutions

**A. Clean up autocmds**

```lua
-- BAD: Creates new autocmd every time
function setup()
  vim.api.nvim_create_autocmd("BufEnter", { callback = fn })
end

-- GOOD: Uses augroup
local group = vim.api.nvim_create_augroup("MyPlugin", { clear = true })
function setup()
  vim.api.nvim_create_autocmd("BufEnter", { 
    group = group,
    callback = fn 
  })
end
```

**B. Stop timers on cleanup**

```lua
local timer = vim.loop.new_timer()
timer:start(1000, 1000, vim.schedule_wrap(function()
  -- work
end))

-- Later, clean up
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    if timer then
      timer:stop()
      timer:close()
    end
  end
})
```

---

## Optimization Workflow

### Step 1: Baseline Measurement

```bash
# Measure startup time (run 10 times, average)
for i in {1..10}; do
  nvim --startuptime /tmp/startup-$i.log -c "quit"
done

# Check average
awk '/^TOTAL/ {sum+=$NF; count++} END {print sum/count}' /tmp/startup-*.log
```

### Step 2: Identify Bottlenecks

```vim
# Open profile
:Lazy profile

# Sort by time (press 't')
# Note plugins > 10ms
```

### Step 3: Apply Optimizations

For each slow plugin:

1. **Check if needed**: Can you remove it?
2. **Lazy-load**: Add `event`, `cmd`, `keys`, or `ft`
3. **Configure**: Reduce features/sources
4. **Replace**: Find faster alternative

### Step 4: Measure Improvement

```bash
# Re-measure
nvim --startuptime /tmp/startup-after.log -c "quit"

# Compare
diff /tmp/startup-before.log /tmp/startup-after.log
```

### Step 5: Test Functionality

**Critical paths to test**:
- `:e lua/plugins/init.lua` - File opening
- `<leader>ff` - Telescope file picker
- `<leader>fw` - Telescope grep
- `:Mason` - Mason UI
- `:Lazy` - Lazy UI
- Open file → `gd` - LSP go-to-definition
- `<leader>ca` - LSP code actions
- Type in insert mode - Completion popup
- `<leader>db` → `<leader>dc` - Debug session

---

## Lazy-loading Strategies

### Strategy 1: Event-based Loading

**Events** (from fastest to slowest):
1. `VeryLazy` - After UI rendered (~200ms after startup)
2. `BufReadPost` - After buffer loaded
3. `BufNewFile` - When creating new file
4. `InsertEnter` - When entering insert mode
5. Custom event (e.g., `LspAttach`)

**Example**:
```lua
-- UI plugins
{ "plugin/ui", event = "VeryLazy" }

-- File-related plugins
{ "plugin/file-utils", event = { "BufReadPost", "BufNewFile" } }

-- Insert mode plugins
{ "plugin/snippets", event = "InsertEnter" }
```

### Strategy 2: Command-based Loading

**Use for**: Plugins with dedicated commands

**Example**:
```lua
-- Lazygit
{ "kdheepak/lazygit.nvim", cmd = "LazyGit" }

-- Mason
{ "williamboman/mason.nvim", cmd = "Mason" }

-- Trouble
{ "folke/trouble.nvim", cmd = "Trouble" }
```

### Strategy 3: Keymap-based Loading

**Use for**: Plugins triggered by specific keymaps

**Example**:
```lua
-- Harpoon
{ "ThePrimeagen/harpoon", keys = {
  { "<leader>h", desc = "Harpoon" }
}}

-- Undotree
{ "mbbill/undotree", keys = {
  { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undotree" }
}}
```

### Strategy 4: Filetype-based Loading

**Use for**: Language-specific plugins

**Example**:
```lua
-- Go
{ "olexsmir/gopher.nvim", ft = "go" }

-- Rust
{ "mrcjkb/rustaceanvim", ft = "rust" }

-- Markdown
{ "MeanderingProgrammer/render-markdown.nvim", ft = "markdown" }
```

### Strategy 5: Dependency-based Loading

**Use for**: Plugins that extend other plugins

**Example**:
```lua
-- Telescope extensions
{
  "nvim-telescope/telescope-frecency.nvim",
  dependencies = "nvim-telescope/telescope.nvim",
  -- Loaded when telescope loads
}
```

---

## Plugin-Specific Optimizations

### Treesitter

**Config**: `lua/configs/treesitter.lua`

**Optimizations**:
1. Reduce `ensure_installed` to only used languages
2. Disable for large files (see Issue 4A above)
3. Disable unused modules (folding, rainbow, etc.)

**Before**:
```lua
ensure_installed = "all",  -- Installs ~100 parsers!
```

**After**:
```lua
ensure_installed = {
  "lua", "vim", "vimdoc",
  "javascript", "typescript", "tsx",
  -- Only languages you use
}
```

### LSP

**Config**: `lua/configs/lspconfig.lua`, `lua/configs/mason-lspconfig.lua`

**Optimizations**:
1. Use `mason-lspconfig` handlers (auto-setup, no manual config)
2. Disable semantic tokens for large files
3. Limit `documentSymbol` requests

**Add to on_attach**:
```lua
-- Disable slow features for large files
local line_count = vim.api.nvim_buf_line_count(bufnr)
if line_count > 10000 then
  client.server_capabilities.semanticTokensProvider = nil
  client.server_capabilities.documentSymbolProvider = nil
end
```

### Telescope

**Plugin**: `lua/plugins/telescope.lua` (via NvChad)

**Optimizations**:
1. Limit `file_ignore_patterns`
2. Use `fd` instead of `find`
3. Reduce `preview` size

**Add to picker defaults**:
```lua
pickers = {
  find_files = {
    find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
  },
}
```

### Blink.cmp (Completion)

**Config**: `lua/plugins/blink-cmp.lua`

**Optimizations**:
1. Reduce sources (see Issue 3A)
2. Limit menu items
3. Increase debounce

**Example**:
```lua
completion = {
  menu = {
    max_items = 50,  -- Default 200
  },
  list = {
    max_items = 50,
  },
},
```

---

## Advanced Techniques

### Profiling Specific Operations

**Technique**: Wrap operation in timer

```lua
local function profile(name, fn)
  local start = vim.loop.hrtime()
  fn()
  local elapsed = (vim.loop.hrtime() - start) / 1e6
  print(string.format("%s took %.2fms", name, elapsed))
end

-- Usage
profile("Telescope find_files", function()
  require('telescope.builtin').find_files()
end)
```

### Conditional Loading Based on Project

```lua
-- In plugin spec
cond = function()
  -- Only load in Git repos
  return vim.fn.isdirectory(".git") == 1
end
```

### Pre-loading Heavy Plugins

For plugins that MUST load on startup but are slow:

```lua
-- In lua/configs/lazy.lua
init = function()
  -- Pre-compile heavy module
  vim.defer_fn(function()
    require("heavy-plugin")
  end, 500)  -- Load 500ms after startup
end
```

### Background Loading

```lua
-- Load non-critical plugins in background
vim.defer_fn(function()
  require("lazy").load({ plugins = { "optional-plugin" } })
end, 1000)
```

---

## Monitoring & Maintenance

### Weekly Performance Check

```bash
# 1. Measure startup
nvim --startuptime /tmp/startup.log -c "quit"
tail -n1 /tmp/startup.log

# 2. Check plugin count
nvim -c "Lazy" -c "qa"
# Count enabled plugins

# 3. Profile top 5 slowest
nvim -c "Lazy profile" -c "qa"
```

### Monthly Deep Dive

1. `:Lazy profile` - Check for new slow plugins
2. `:Lazy clean` - Remove unused plugins
3. `:Mason` - Update LSP servers, check for new optimizations
4. Review `lua/configs/treesitter.lua` - Remove unused parsers
5. Test in large file (>10k lines) - Check scroll performance

### Performance Regression Detection

After ANY config change:

```bash
# Before
nvim --startuptime /tmp/before.log -c "quit"

# Make changes

# After
nvim --startuptime /tmp/after.log -c "quit"

# Compare
diff /tmp/before.log /tmp/after.log
```

**Red flags**:
- Total time increase > 10ms
- New plugin loading on startup
- Increased sourcing time for existing files

---

## Performance Checklist

Use this before committing config changes:

```
[ ] Startup time < 100ms (cold), < 50ms (warm)
[ ] All plugins lazy-loaded (except required core)
[ ] No heavy operations in sync code
[ ] Autocmds use augroups
[ ] LSP optimized for large files
[ ] Treesitter limited to used languages
[ ] Completion debounced appropriately
[ ] No memory leaks (check with collectgarbage)
[ ] Tested critical paths (file open, search, LSP)
[ ] :Lazy profile shows no plugins > 20ms
[ ] :checkhealth reports no performance issues
```

---

## Troubleshooting Slow Performance

### General Approach

1. **Measure**: `nvim --startuptime startup.log`
2. **Identify**: `:Lazy profile`, sort by time
3. **Isolate**: Disable suspected plugin, re-measure
4. **Fix**: Apply optimizations from this guide
5. **Verify**: Re-measure, test functionality

### Emergency: Config is Unusably Slow

```bash
# 1. Start with minimal config
nvim --clean

# 2. If fast, problem is in config
# Bisect plugins:
mv lua/plugins lua/plugins.bak
mkdir lua/plugins
cp lua/plugins.bak/init.lua lua/plugins/

# 3. Add plugins back one-by-one
# Test after each: nvim --startuptime /tmp/test.log
```

### Diagnostic Commands

```vim
# Check what's loading
:Lazy

# Profile startup
:Lazy profile

# Check LSP status
:LspInfo

# Check memory usage
:lua print(collectgarbage("count"))

# Check treesitter status
:TSModuleInfo

# Health check
:checkhealth
```

---

## Real-World Examples

### Example 1: Optimizing New Plugin

**Before**:
```lua
{
  "plugin/name",
  config = function()
    require("plugin").setup()
  end
}
```

**Analysis**: Loads on startup, 35ms load time

**After**:
```lua
{
  "plugin/name",
  cmd = "PluginCommand",  -- Lazy-load on command
  config = function()
    require("plugin").setup()
  end
}
```

**Result**: 0ms on startup, 35ms when first used

### Example 2: Slow Telescope

**Problem**: `find_files` takes 2+ seconds

**Diagnosis**:
```vim
:checkhealth telescope
# Shows: Using 'find' instead of 'fd'
```

**Solution**: Install `fd` and configure
```bash
# Install fd
sudo dnf install fd-find  # or apt/pacman/brew

# Telescope auto-uses fd if available
```

**Result**: `find_files` < 500ms

### Example 3: Slow LSP in Large File

**Problem**: LSP hangs in 20k line file

**Solution** (in `lspconfig.lua`):
```lua
local function on_attach(client, bufnr)
  if vim.api.nvim_buf_line_count(bufnr) > 10000 then
    -- Disable slow features
    client.server_capabilities.semanticTokensProvider = nil
    client.server_capabilities.documentSymbolProvider = nil
    
    -- Increase debounce
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
        update_in_insert = false,
        debounce = 500,  -- Increased from default
      }
    )
  end
end
```

---

## Best Practices

1. **Lazy by default**: Set `defaults = { lazy = true }` in lazy config
2. **Measure before optimizing**: Don't guess, profile first
3. **Test after changes**: Always verify functionality still works
4. **One change at a time**: Makes debugging easier
5. **Document optimizations**: Comment why you disabled something
6. **Keep baseline**: Save `startup.log` to compare against
7. **Balance speed vs features**: Don't sacrifice needed functionality
8. **Profile in realistic scenarios**: Test with actual project files
9. **Update regularly**: New plugin versions may have optimizations
10. **Share configs**: Learn from others' optimization strategies

---

## Quick Reference

### Profiling Commands
```bash
nvim --startuptime startup.log      # Startup profile
nvim --startuptime startup.log -c "quit"  # Non-interactive
```

### In-Neovim Commands
```vim
:Lazy profile           # Plugin load times
:LspInfo                # LSP server status
:checkhealth lazy       # Lazy.nvim health
:checkhealth telescope  # Telescope health
:TSModuleInfo           # Treesitter status
:lua print(collectgarbage("count"))  # Memory usage
```

### Key Files
- `lua/configs/lazy.lua` - Lazy loading defaults
- `lua/configs/treesitter.lua` - Treesitter config
- `lua/configs/lspconfig.lua` - LSP config
- `lua/plugins/blink-cmp.lua` - Completion config

### Performance Targets
- Cold start: < 100ms
- Warm start: < 50ms
- Plugin load: < 200ms total
- LSP attach: < 500ms
- Completion: < 50ms

---

**Remember**: Performance optimization is iterative. Measure, optimize, verify, repeat.
