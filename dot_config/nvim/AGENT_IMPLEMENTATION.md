# Implementation Agent - New Plugin Integration

**Role**: Add new plugins, integrate with existing config, and modify Neovim configuration.

## Pre-Implementation Checklist
Before adding any new plugin:
1. Read `AGENTS.md` for code style and patterns
2. Check `lua/plugins/` directory - the plugin might already exist with `enabled = false`
3. Search for similar functionality in existing plugins (83 plugins currently installed)
4. Verify plugin is actively maintained (check GitHub stars, recent commits, issues)
5. Create feature branch: `git checkout -b feat/plugin-name`

## Plugin Implementation Workflow

### Step 1: Research the Plugin
**Find official documentation:**
```bash
# Use browser or fetch plugin README
# Example: https://github.com/author/plugin-name
```

**Key information to gather:**
- [ ] Plugin repository URL (e.g., `"author/plugin-name"`)
- [ ] Latest stable version or branch
- [ ] Required dependencies (other plugins, external tools)
- [ ] Minimum Neovim version
- [ ] Default configuration options
- [ ] Recommended keymaps
- [ ] Lazy-loading strategy (`event`, `cmd`, `keys`, `ft`)
- [ ] Mason packages needed (LSPs, formatters, linters)

### Step 2: Check for Existing Installation
```bash
# Search existing plugins
grep -r "plugin-name" lua/plugins/

# Check if disabled
grep "enabled = false" lua/plugins/*.lua | grep -i "plugin-name"
```

**If plugin exists but is disabled:**
- Read the plugin file to understand why it was disabled
- Update configuration rather than creating new file
- Change `enabled = false` to `enabled = true`

### Step 3: Create Plugin Spec File
**Location**: `lua/plugins/plugin-name.lua`

**Template for new plugin:**
```lua
return {
  "author/plugin-name",
  -- Lazy-loading (choose one or more)
  event = "VeryLazy",              -- Load after UI is ready
  -- cmd = "CommandName",          -- Load on command
  -- keys = { "<leader>key" },     -- Load on keymap
  -- ft = { "rust", "go" },        -- Load for filetypes
  
  -- Dependencies (if needed)
  dependencies = {
    "nvim-lua/plenary.nvim",       -- Common dependency
  },
  
  -- Build step (if needed)
  -- build = "make",
  -- build = ":TSUpdate",
  
  -- Simple config
  opts = {
    -- Plugin options here
  },
  
  -- OR complex config with function
  config = function()
    require("plugin-name").setup {
      -- Configuration here
    }
  end,
}
```

**Lazy-loading strategy guide:**
- `event = "VeryLazy"` - Non-critical UI plugins (default choice)
- `event = "BufReadPost"` - File editing plugins
- `event = "InsertEnter"` - Completion/snippet plugins
- `cmd = "Command"` - Only when command is called
- `keys = { "<leader>x" }` - Only when keymap is pressed
- `ft = "filetype"` - Only for specific file types
- `lazy = false` - Load immediately (avoid if possible)

### Step 4: Add Configuration (if complex)
**If plugin needs extensive config** (>50 lines), create separate config file:

**Location**: `lua/configs/plugin-name.lua`

**Template:**
```lua
-- lua/configs/plugin-name.lua
local options = {
  -- All plugin configuration
  setting1 = true,
  setting2 = {
    nested = "value",
  },
}

return options
```

**Then reference in plugin file:**
```lua
-- lua/plugins/plugin-name.lua
return {
  "author/plugin-name",
  event = "VeryLazy",
  opts = function()
    return require "configs.plugin-name"
  end,
}
```

### Step 5: Add Keymaps (if needed)
**Location**: `lua/mappings.lua`

**Add to appropriate section** with `----- SECTION -----` headers:

**Template:**
```lua
----- PLUGIN NAME -----
M("n", "<leader>pk", "<cmd>PluginCommand<cr>", { desc = "Plugin action" })

-- With Lua function
M("n", "<leader>pt", function()
  require("plugin-name").toggle()
end, { desc = "Toggle plugin" })

-- Filetype-specific (use autocmd)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    M("n", "<leader>ra", function()
      require("plugin-name").action()
    end, { desc = "Plugin action for Rust" })
  end,
})
```

**Keymap conventions:**
- Use descriptive `desc` field for discoverability (`:Telescope keymaps`)
- Follow existing leader key patterns (`:help leader` defaults to `<Space>`)
- Common prefixes: `<leader>f` (find/file), `<leader>l` (LSP), `<leader>g` (git)
- Use `M()` helper function from `lua/mappings.lua`

### Step 6: Add Mason Packages (if needed)
**For LSPs, formatters, linters, DAP adapters:**

**Location**: `lua/chadrc.lua`

**Add to `M.mason.pkgs` table:**
```lua
M.mason = {
  pkgs = {
    -- ... existing packages ...
    "new-lsp-server",
    "new-formatter",
    "new-linter",
  },
}
```

**Then configure in appropriate file:**
- LSP: `lua/configs/lspconfig.lua`
- Formatter: `lua/configs/conform.lua`
- Linter: `lua/configs/lint.lua`

### Step 7: Integration with Existing Plugins

**Common integrations:**

**1. Telescope integration:**
```lua
-- In plugin config
config = function()
  require("plugin-name").setup()
  require("telescope").load_extension "plugin_name"
end,

-- In mappings.lua
M("n", "<leader>fp", function()
  require("telescope").extensions.plugin_name.action()
end, { desc = "Telescope plugin action" })
```

**2. Which-key integration (if using):**
```lua
-- Group related keymaps
-- Already auto-discovered via `desc` field in keymaps
```

**3. LSP integration:**
```lua
-- In lua/configs/lspconfig.lua
local on_attach = function(client, bufnr)
  -- Existing on_attach code...
  
  -- Plugin-specific setup
  if client.server_capabilities.documentSymbolProvider then
    require("plugin-name").on_attach(client, bufnr)
  end
end
```

**4. Completion integration (blink.cmp):**
```lua
-- In lua/plugins/blink-cmp.lua
sources = {
  default = { "lsp", "path", "snippets", "buffer", "copilot", "avante", "plugin_name" },
  providers = {
    plugin_name = {
      name = "plugin_name",
      module = "blink-cmp-plugin",
      score_offset = 10,
    },
  },
},
```

### Step 8: Testing & Validation

**Immediate testing:**
```bash
# 1. Open Neovim
nvim

# 2. Check plugin loaded
:Lazy

# 3. Check for errors
:checkhealth

# 4. Test plugin command
:PluginCommand

# 5. Test keymaps work
# Press configured keymaps
```

**Validation checklist:**
- [ ] Plugin loads without errors (`:Lazy`)
- [ ] No breaking changes to existing functionality
- [ ] Keymaps work as expected
- [ ] No performance degradation (`:Lazy profile`)
- [ ] LSP/completion still works (if relevant)
- [ ] Format/lint still works (if relevant)
- [ ] No conflicts with disabled plugins

**Performance check:**
```vim
:Lazy profile
```
Target: Plugin should load in < 10ms unless it's a heavy plugin (treesitter, LSP, etc.)

**Code quality check:**
```bash
# Format
stylua .

# Lint
luacheck lua/ --globals vim

# Verify no errors
nvim --headless -c "quit"
```

### Step 9: Documentation

**In plugin file comments:**
```lua
-- Plugin: author/plugin-name
-- Purpose: Brief description of what it does
-- Docs: https://github.com/author/plugin-name
-- Note: Any special considerations or conflicts
return {
  "author/plugin-name",
  -- ...
}
```

**Update README.md (if significant):**
- Add to plugin highlights section
- Document new keymaps if not obvious
- Note any new dependencies or Mason packages

### Step 10: Commit Changes

**Commit message format:**
```bash
# For new plugin
git add lua/plugins/plugin-name.lua lua/mappings.lua
git commit -m "feat: add plugin-name for X functionality

- Add plugin-name plugin with lazy-loading
- Configure keymaps for common actions
- Integrate with existing telescope/lsp setup
- Add required Mason packages"

# For plugin configuration changes
git commit -m "feat: configure plugin-name with custom options

- Customize behavior for Y use case
- Add keymaps for Z actions
- Fix conflict with existing plugin"

# For enabling disabled plugin
git commit -m "feat: enable plugin-name

- Update configuration to latest version
- Resolve previous issues that caused disabling
- Add keymaps for new features"
```

## Common Plugin Categories & Patterns

### LSP Plugins
**Pattern: Language-specific tools**
```lua
return {
  "language-plugin",
  ft = { "rust", "go" },  -- Load only for filetypes
  config = function()
    require "configs.language"
  end,
}
```

### Completion Sources
**Pattern: Integrate with blink.cmp**
```lua
-- Edit lua/plugins/blink-cmp.lua
sources = {
  providers = {
    new_source = {
      name = "new_source",
      module = "blink-cmp-new-source",
      score_offset = 50,
    },
  },
},
```

### UI Plugins
**Pattern: Lazy load, non-critical**
```lua
return {
  "ui-plugin",
  event = "VeryLazy",
  opts = {
    -- Minimal config
  },
}
```

### Git Plugins
**Pattern: cmd or keymap triggered**
```lua
return {
  "git-plugin",
  cmd = { "GitCommand" },
  keys = {
    { "<leader>gg", "<cmd>GitCommand<cr>", desc = "Git action" },
  },
  dependencies = { "nvim-lua/plenary.nvim" },
}
```

### Telescope Extensions
**Pattern: Load with telescope**
```lua
return {
  "telescope-extension",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("telescope").load_extension "extension_name"
  end,
}
```

## Troubleshooting

**Plugin doesn't load:**
- Check `:Lazy` for errors
- Verify lazy-loading trigger (try `lazy = false` temporarily)
- Check dependencies are installed

**Conflicts with existing plugins:**
- Search for `enabled = false` plugins providing similar functionality
- Check keymaps don't conflict (`:Telescope keymaps`)
- Review plugin's on_attach if LSP-related

**Performance issues:**
- Use `:Lazy profile` to identify slow plugins
- Add stricter lazy-loading (`event`, `cmd`, `keys` instead of `VeryLazy`)
- Consider `enabled = false` for non-essential plugins

**Breaking existing config:**
- Rollback: `git checkout HEAD~1 lua/plugins/plugin-name.lua`
- Check plugin documentation for breaking changes
- Test in isolated config first

## NvChad-Specific Considerations

**Don't override NvChad defaults unless necessary:**
- NvChad has its own configs in `nvchad.configs.*`
- Use `vim.tbl_deep_extend("force", nvchad_opts, custom_opts)` to merge
- Example in `lua/plugins/init.lua` for nvim-tree

**Use on_attach wrapper for LSP:**
```lua
-- In lua/configs/lspconfig.lua
local nv_on_attach = require("nvchad.configs.lspconfig").on_attach

local on_attach = function(client, bufnr)
  nv_on_attach(client, bufnr)
  -- Custom on_attach code
  -- Remove conflicting keymaps if needed
  pcall(vim.keymap.del, "n", "<leader>ra", { buffer = bufnr })
end
```

**Completion engine note:**
- This config uses `blink.cmp` NOT `nvim-cmp`
- `nvim-cmp` is disabled in `lua/plugins/nvim-cmp.lua`
- Don't add nvim-cmp sources - use blink.cmp providers

## Examples of Well-Implemented Plugins

**Reference these for patterns:**
- `lua/plugins/blink-cmp.lua` - Complex config with providers
- `lua/plugins/harpoon.lua` - Simple with keymaps
- `lua/plugins/rustaceanvim.lua` - Language-specific with configs
- `lua/plugins/telescope.nvim` (in init.lua) - Extends NvChad defaults
- `lua/plugins/gitsigns.lua` - Keymaps in mappings.lua

## Final Checklist
Before submitting/committing:
- [ ] Read plugin documentation thoroughly
- [ ] Check for existing similar functionality
- [ ] Follow code style from AGENTS.md
- [ ] Add proper lazy-loading strategy
- [ ] Add keymaps with descriptive `desc`
- [ ] Test plugin works without errors
- [ ] Check performance with `:Lazy profile`
- [ ] Format code with `stylua .`
- [ ] Lint code with `luacheck lua/ --globals vim`
- [ ] Commit with descriptive message
- [ ] Document in code comments
