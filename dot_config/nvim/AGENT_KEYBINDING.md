# Keybinding & Keymap Customization Specialist Agent

This agent specializes in adding, modifying, and troubleshooting keybindings in the NvChad configuration. It covers global mappings, plugin-specific mappings, leader key conventions, and conflict resolution.

## When to Use This Agent

Use this agent when:
- Adding new keybindings or shortcuts
- Modifying existing keybindings
- Resolving keymap conflicts
- Understanding the keymap structure
- Setting up which-key integration
- Creating mode-specific mappings
- Troubleshooting non-working keybindings

## Keybinding Architecture

### File Structure

```
lua/
  mappings.lua              # All custom keybindings (466 lines)
  plugins/
    {plugin}.lua            # Plugin specs with keys = {...}
nvchad/
  mappings.lua              # NvChad default mappings (loaded first)
```

### Loading Order

1. **NvChad defaults** - `require "nvchad.mappings"` (line 1 of mappings.lua)
2. **Custom mappings** - Rest of `lua/mappings.lua`
3. **Plugin-specific** - Lazy-loaded with plugins via `keys = {...}`

## Keymap Helper Function

**Location**: `lua/mappings.lua:3-10`

```lua
local map = vim.keymap.set
local del = vim.keymap.del
local default_opts = { noremap = true, silent = true }
local function M(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", default_opts, opts or {})
  map(mode, lhs, rhs, opts)
end
```

**Usage**: All mappings use the `M()` helper which:
- Automatically adds `noremap = true, silent = true`
- Merges custom opts with defaults
- Provides consistent mapping interface

**Examples**:

```lua
-- Simple mapping
M("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

-- Mapping with function
M("n", "<leader>u", function()
  vim.cmd("UndotreeToggle")
end, { desc = "Toggle UndoTree" })

-- Override default opts
M("n", ";", ":", { desc = "Enter command mode", silent = false })

-- Multiple modes
M({ "n", "v" }, "<leader>D", [["_d]], { desc = "Delete without yanking" })
```

## Leader Key Configuration

**Leader**: `<space>` (NvChad default)
**Local leader**: `\` (Vim default, not commonly used in this config)

### Leader Key Hierarchy

```
<leader>      (space)
├── b         Buffer operations
├── c         Code/Comments
├── d         Debugger (DAP)
├── f         Find (Telescope)
├── g         Git
├── h         Help/Documentation
├── l         LSP
├── o         Obsidian
├── q/Q       Quit
├── r         Rust-specific (in Rust files)
├── s         Search/Session
├── t         Terminal/Testing
├── u         Undotree
├── w         Window operations
├── x/X       Close buffer
└── z         Zen mode
```

## Keymap Categories

### 1. Basic Navigation & Editing

**Location**: `lua/mappings.lua:15-33`

```lua
-- Command mode shortcut
M("n", ";", ":", { desc = "Enter command mode" })

-- Scroll with centering
M("n", "<C-d>", "<C-d>zz", { desc = "Scroll down & center" })
M("n", "<C-u>", "<C-u>zz", { desc = "Scroll up & center" })

-- Search with centering
M("n", "n", "nzzzv", { desc = "Next search & center" })
M("n", "N", "Nzzzv", { desc = "Prev search & center" })

-- Quit shortcuts
M("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
M("n", "<leader>Q", "<cmd>q!<CR>", { desc = "Force quit" })

-- Paste without overwriting register
M("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

-- Delete without yanking
M({ "n", "v" }, "<leader>D", [["_d]], { desc = "Delete without yanking" })

-- Select last paste/change
M("n", "<leader>gv", "`[v`]", { desc = "Visually select last paste/change" })

-- Disable Ex mode
M("n", "Q", "<nop>", { desc = "Disable Ex mode" })
```

### 2. File Operations

**Location**: `lua/mappings.lua:34-43`

```lua
-- Copy file with context for LLM
M("n", "<C-c>", require "functions.file_context", { desc = "Copy file with context for LLM" })
```

### 3. Buffer Management

**Location**: `lua/mappings.lua:50-54`

```lua
M("n", "<leader>x", "<cmd>bd<cr>", { desc = "Close buffer" })
M("n", "<leader>X", "<cmd>bd!<cr>", { desc = "Force close buffer" })
```

### 4. Line/Selection Movement (Mini.move)

**Location**: `lua/mappings.lua:56-80`

```lua
-- Move lines/selections with Alt+hjkl
M("n", "<M-h>", function() mini_move.move_line("left") end, { desc = "Move line left" })
M("v", "<M-h>", function() mini_move.move_selection("left") end, { desc = "Move selection left" })
M("n", "<M-l>", function() mini_move.move_line("right") end, { desc = "Move line right" })
M("v", "<M-l>", function() mini_move.move_selection("right") end, { desc = "Move selection right" })
M("n", "<M-k>", function() mini_move.move_line("up") end, { desc = "Move line up" })
M("v", "<M-k>", function() mini_move.move_selection("up") end, { desc = "Move selection up" })
M("n", "<M-j>", function() mini_move.move_line("down") end, { desc = "Move line down" })
M("v", "<M-j>", function() mini_move.move_selection("down") end, { desc = "Move selection down" })
```

### 5. Terminal

**Location**: `lua/mappings.lua:82-84`

```lua
M("n", "<leader>th", "<cmd>split | terminal<CR>", { desc = "Horizontal Terminal" })
M("n", "<leader>tv", "<cmd>vsplit | terminal<CR>", { desc = "Vertical Terminal" })
```

**Note**: NvChad default `<leader>ch` and `<leader>th` are deleted (lines 46-47)

### 6. LSP (Language Server Protocol)

**Location**: `lua/mappings.lua:89-158`

**Important**: LSP keymaps are set via `LspAttach` autocmd, so they only exist when LSP attaches.

```lua
-- Navigation
M("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
M("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
M("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
M("n", "<leader>lT", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
M("n", "gr", vim.lsp.buf.references, { desc = "List references" })

-- Refactoring
M("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename symbol" })

-- Formatting
M("n", "<leader>lf", function()
  require("conform").format({ lsp_fallback = true })
end, { desc = "Format buffer" })

-- Diagnostics (native alternatives to LSPsaga)
M("n", "<leader>ll", vim.diagnostic.open_float, { desc = "Show diagnostics (native)" })
M("n", "[D", vim.diagnostic.goto_prev, { desc = "Previous diagnostic (native)" })
M("n", "]D", vim.diagnostic.goto_next, { desc = "Next diagnostic (native)" })

-- LSP management
M("n", "<leader>lh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufn }), { bufnr = bufn })
end, { desc = "Toggle inlay hints" })

M("n", "<leader>ld", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled({ bufnr = bufn }), { bufnr = bufn })
end, { desc = "Toggle diagnostics" })

M("n", "<leader>lH", function()
  -- Toggle harper_ls (grammar checker)
  local clients = vim.lsp.get_clients({ bufnr = bufn, name = "harper_ls" })
  if #clients > 0 then
    vim.lsp.stop_client(clients[1].id)
  else
    vim.cmd("LspStart harper_ls")
  end
end, { desc = "Toggle Harper LSP (grammar)" })

M("n", "<leader>li", "<cmd>LspInfo<cr>", { desc = "LSP info" })
M("n", "<leader>lR", "<cmd>LspRestart<cr>", { desc = "Restart LSP" })
```

**Note**: Some LSP keymaps are commented out in favor of LSPsaga alternatives (K for hover, gl for diagnostics, <leader>la for code actions).

### 7. Git (Gitsigns)

**Location**: `lua/mappings.lua:170-218`

```lua
-- Blame
M("n", "<leader>gb", function() require("gitsigns").toggle_current_line_blame() end, { desc = "Toggle git blame" })
M("n", "<leader>gB", function() require("gitsigns").blame_line({ full = true }) end, { desc = "Full git blame" })

-- Diff
M("n", "<leader>gd", function() require("gitsigns").diffthis() end, { desc = "Git diff" })
M("n", "<leader>gD", function() require("gitsigns").diffthis("~") end, { desc = "Git diff against last commit" })

-- Hunk operations
M("n", "<leader>gp", function() require("gitsigns").preview_hunk() end, { desc = "Preview hunk" })
M("n", "<leader>gr", function() require("gitsigns").reset_hunk() end, { desc = "Reset hunk" })
M("n", "<leader>gR", function() require("gitsigns").reset_buffer() end, { desc = "Reset buffer" })
M("n", "<leader>gs", function() require("gitsigns").stage_hunk() end, { desc = "Stage hunk" })
M("n", "<leader>gS", function() require("gitsigns").stage_buffer() end, { desc = "Stage buffer" })
M("n", "<leader>gu", function() require("gitsigns").undo_stage_hunk() end, { desc = "Undo stage hunk" })

-- Navigation
M("n", "]g", function() require("gitsigns").next_hunk() end, { desc = "Next git hunk" })
M("n", "[g", function() require("gitsigns").prev_hunk() end, { desc = "Previous git hunk" })
```

### 8. Language-Specific Keymaps

#### Rust (rustaceanvim)

**Location**: `lua/mappings.lua:220-300`

**Important**: These are FileType autocmds, so they only load for Rust files.

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    -- Code actions & diagnostics
    M("n", "<leader>ra", function() vim.cmd.RustLsp("codeAction") end, { desc = "Code actions" })
    M("n", "K", function() vim.cmd.RustLsp({ "hover", "actions" }) end, { desc = "Hover actions" })
    M("n", "<leader>re", function() vim.cmd.RustLsp("explainError") end, { desc = "Explain error" })
    M("n", "<leader>rd", function() vim.cmd.RustLsp("renderDiagnostic") end, { desc = "Render diagnostic" })
    
    -- Running & debugging
    M("n", "<leader>rr", function() vim.cmd.RustLsp("runnables") end, { desc = "Runnables" })
    M("n", "<leader>rD", function() vim.cmd.RustLsp("debuggables") end, { desc = "Debuggables" })
    M("n", "<leader>rt", function() vim.cmd.RustLsp("testables") end, { desc = "Testables" })
    
    -- Code exploration
    M("n", "<leader>rE", function() vim.cmd.RustLsp("expandMacro") end, { desc = "Expand macro" })
    M("n", "<leader>rc", function() vim.cmd.RustLsp("openCargo") end, { desc = "Open Cargo.toml" })
    
    -- Cargo commands
    M("n", "<leader>Cb", "<cmd>Cargo build<cr>", { desc = "Cargo build" })
    M("n", "<leader>Cr", "<cmd>Cargo run<cr>", { desc = "Cargo run" })
    M("n", "<leader>Ct", "<cmd>Cargo test<cr>", { desc = "Cargo test" })
    M("n", "<leader>Cc", "<cmd>Cargo check<cr>", { desc = "Cargo check" })
  end,
})
```

#### Go

**Location**: `lua/mappings.lua:302-311` (approximate)

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    M("n", "<leader>ga", "<cmd>GoAlternate<cr>", { desc = "Go alternate test/impl" })
    M("n", "<leader>gt", function() require("neotest").run.run() end, { desc = "Run nearest test" })
  end,
})
```

### 9. Obsidian

**Location**: `lua/mappings.lua:160-168`

```lua
M("n", "<leader>oc", "<cmd>lua require('obsidian').util.toggle_checkbox()<CR>", { desc = "Toggle checkbox" })
M("n", "<leader>ot", "<cmd>Obsidian template<CR>", { desc = "Insert template" })
M("n", "<leader>oo", "<cmd>Obsidian open<CR>", { desc = "Open in app" })
M("n", "<leader>ob", "<cmd>Obsidian backlinks<CR>", { desc = "Show backlinks" })
M("n", "<leader>ol", "<cmd>Obsidian links<CR>", { desc = "Show links" })
M("n", "<leader>on", "<cmd>Obsidian new<CR>", { desc = "New note" })
M("n", "<leader>os", "<cmd>Obsidian search<CR>", { desc = "Search notes" })
M("n", "<leader>oq", "<cmd>Obsidian quick_switch<CR>", { desc = "Quick switch" })
```

### 10. Plugin-Specific Mappings (Lazy-loaded)

Plugins can define keymaps in their specs using the `keys` field:

**Example**: `lua/plugins/harpoon.lua`

```lua
{
  "ThePrimeagen/harpoon",
  keys = {
    { "<leader>a", function() require("harpoon.mark").add_file() end, desc = "Harpoon add file" },
    { "<C-e>", function() require("harpoon.ui").toggle_quick_menu() end, desc = "Harpoon menu" },
    { "<C-h>", function() require("harpoon.ui").nav_file(1) end, desc = "Harpoon file 1" },
    { "<C-t>", function() require("harpoon.ui").nav_file(2) end, desc = "Harpoon file 2" },
    { "<C-n>", function() require("harpoon.ui").nav_file(3) end, desc = "Harpoon file 3" },
    { "<C-s>", function() require("harpoon.ui").nav_file(4) end, desc = "Harpoon file 4" },
  },
}
```

**Example**: `lua/plugins/flash.lua`

```lua
{
  "folke/flash.nvim",
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
```

## Adding New Keybindings

### Step 1: Decide on Key Location

**Global mappings** → `lua/mappings.lua`
**Plugin-specific mappings** → Plugin spec `keys = {...}`
**Language-specific mappings** → FileType autocmd in `lua/mappings.lua`
**LSP mappings** → Inside LspAttach autocmd in `lua/mappings.lua`

### Step 2: Choose Key Combination

**Check for conflicts** first:

```vim
" In Neovim
:map <key>         " Show all modes
:nmap <key>        " Normal mode
:vmap <key>        " Visual mode
:imap <key>        " Insert mode
```

**Available keys**:
- `<leader>{key}` - Most flexible, follows hierarchy
- `<C-{key}>` - Control key combinations
- `<M-{key}>` - Alt/Meta key combinations (good for movement)
- `g{key}` - Go/navigation prefix
- `]/{key}`, `[{key}` - Next/previous prefix
- Function keys `<F1>` through `<F12>`

**Avoid**:
- Single letters in normal mode (reserved for Vim motions)
- NvChad defaults unless intentionally overriding
- Common Vim conventions (dd, yy, gg, G, etc.)

### Step 3: Add to Appropriate Location

**Example: Global mapping**

```lua
-- Add to lua/mappings.lua in appropriate section
M("n", "<leader>my", function()
  print("My custom function")
end, { desc = "My custom keybinding" })
```

**Example: Plugin-specific mapping**

```lua
-- In lua/plugins/myplugin.lua
{
  "author/myplugin",
  keys = {
    { "<leader>mp", function() require("myplugin").open() end, desc = "Open my plugin" },
  },
}
```

**Example: Language-specific mapping**

```lua
-- Add to lua/mappings.lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    M("n", "<leader>pr", "<cmd>!python %<cr>", { desc = "Run Python file" })
  end,
})
```

**Example: LSP mapping**

```lua
-- Add inside LspAttach callback in lua/mappings.lua
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local bufn = ev.buf
    -- ... existing mappings ...
    
    M("n", "<leader>lm", vim.lsp.buf.format, 
      vim.tbl_extend("force", opts, { desc = "My LSP mapping" }))
  end,
})
```

### Step 4: Test the Keybinding

```vim
" Open Neovim
nvim

" Test the mapping
<your-key>

" Check which-key (if using leader key)
<space>   # Wait for which-key popup

" Verify mapping exists
:map <your-key>

" Check for conflicts
:verbose map <your-key>
```

## Deleting/Overriding Keybindings

### Deleting NvChad Defaults

**Location**: `lua/mappings.lua:45-48`

```lua
local del = vim.keymap.del

-- Delete unwanted NvChad mappings
del("n", "<leader>ch")  -- Cheatsheet
del("n", "<leader>th")  -- Theme switcher
del("n", "<leader>fm")  -- Format (using custom instead)
```

### Overriding Existing Mappings

Simply remap the same key in `lua/mappings.lua`:

```lua
-- NvChad default for <leader>q might be something else
-- Override it
M("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
```

### Disabling a Key Completely

```lua
M("n", "Q", "<nop>", { desc = "Disable Ex mode" })
```

## Keymap Modes

```lua
-- Modes
"n"     -- Normal mode
"i"     -- Insert mode
"v"     -- Visual and Select mode
"x"     -- Visual mode only
"s"     -- Select mode
"o"     -- Operator-pending mode
"c"     -- Command-line mode
"t"     -- Terminal mode

-- Multiple modes
{ "n", "v" }      -- Normal and Visual
{ "n", "x", "o" } -- Normal, Visual, and Operator-pending
```

**Examples**:

```lua
-- Normal mode only
M("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

-- Visual mode only
M("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

-- Multiple modes
M({ "n", "v" }, "<leader>D", [["_d]], { desc = "Delete without yanking" })

-- Insert mode
M("i", "<C-s>", "<Esc><cmd>w<CR>", { desc = "Save in insert mode" })

-- Terminal mode
M("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
```

## Which-Key Integration

Which-key automatically shows available keybindings when you press the leader key.

**Configuration**: Handled by NvChad, no custom config needed.

**How it works**:
1. Press `<leader>` (space)
2. Wait ~300ms
3. Which-key popup appears showing all available leader mappings
4. The `desc` field from each mapping is displayed

**Important**: Always include `desc` in your mappings for which-key discoverability:

```lua
-- ✅ Good - has description
M("n", "<leader>my", function() ... end, { desc = "My action" })

-- ❌ Bad - no description (will show as "which_key_ignore")
M("n", "<leader>my", function() ... end)
```

**Grouping in which-key**:

Which-key automatically groups by prefix. For example:
- `<leader>g` shows all Git operations
- `<leader>l` shows all LSP operations
- `<leader>d` shows all DAP operations

To create a custom group description:

```lua
-- This is typically handled by which-key config, but you can also do:
require("which-key").register({
  ["<leader>m"] = { name = "+My Custom Group" }
})
```

## Troubleshooting

### Issue: Keybinding Not Working

**Debug steps**:

1. Check if mapping exists:
   ```vim
   :map <your-key>
   ```

2. Check for conflicts:
   ```vim
   :verbose map <your-key>
   ```
   Shows which file set the mapping last

3. Check if plugin is loaded:
   ```vim
   :Lazy
   ```
   Verify plugin with keymap is loaded

4. Check mode is correct:
   ```vim
   :nmap <key>   # Normal mode
   :vmap <key>   # Visual mode
   ```

5. Test in fresh config:
   ```bash
   nvim --clean -c "set runtimepath+=~/.config/nvim" -c "lua require('mappings')"
   ```

**Common issues**:

```lua
-- Issue: Plugin not loaded yet (lazy-loaded)
-- Fix: Use keys = {...} in plugin spec instead

-- Issue: Wrong mode
M("n", "<leader>p", ...) -- Only works in normal mode
-- Fix: Add visual mode
M({ "n", "v" }, "<leader>p", ...)

-- Issue: Conflicting with NvChad default
-- Fix: Delete NvChad mapping first
del("n", "<leader>ch")
M("n", "<leader>ch", ...) -- Now works
```

### Issue: Keymap Conflicts

**Symptoms**: Pressing key does unexpected action

**Debug**:

```vim
:verbose map <key>
```

Shows all mappings for that key and which file set them.

**Resolution strategies**:

1. **Delete conflicting mapping**:
   ```lua
   del("n", "<leader>ra")  -- Delete old mapping
   M("n", "<leader>ra", ...) -- Add new mapping
   ```

2. **Choose different key**:
   ```lua
   -- Instead of conflicting <leader>ra
   M("n", "<leader>rA", ...) -- Use uppercase variant
   ```

3. **Make it filetype-specific**:
   ```lua
   -- Only for Rust files
   vim.api.nvim_create_autocmd("FileType", {
     pattern = "rust",
     callback = function()
       M("n", "<leader>ra", ...)
     end,
   })
   ```

### Issue: Which-Key Not Showing Mapping

**Symptoms**: Mapping works but doesn't appear in which-key popup

**Causes**:
1. Missing `desc` field
2. Mapping set after which-key initialization
3. Mapping uses `silent = false` (which-key only shows silent mappings)

**Fix**:

```lua
-- Always include desc
M("n", "<leader>my", function() ... end, { desc = "My action" })

-- Not this
M("n", "<leader>my", function() ... end)
```

### Issue: LSP Keymaps Not Working

**Symptoms**: LSP keymaps like `gd`, `gr` don't work

**Debug**:

1. Check if LSP attached:
   ```vim
   :LspInfo
   ```

2. Check if LspAttach autocmd fired:
   ```vim
   :autocmd LspAttach
   ```

3. Check if keymap exists in buffer:
   ```vim
   :map gd
   ```
   Should show buffer-local mapping

**Common causes**:

```lua
-- Issue: LSP not attaching
-- Fix: Check lua/configs/lspconfig.lua

-- Issue: Keymap not in LspAttach autocmd
-- Fix: Move keymap inside LspAttach callback
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    M("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
  end,
})
```

### Issue: Function Keys Not Working

**Symptoms**: `<F1>`, `<F2>`, etc. don't work

**Cause**: Terminal might be intercepting function keys

**Debug**:

```vim
" Type this in insert mode
<C-v><F1>

" Should output something like ^[[11~
" If it outputs nothing, terminal is intercepting
```

**Fix**:
- Use different keys: `<leader>{key}`
- Configure terminal to pass function keys through
- Use alternative like `<C-{key}>`

## Best Practices

### 1. Always Include `desc` Field

✅ **Do**:
```lua
M("n", "<leader>my", function() ... end, { desc = "My action" })
```

❌ **Don't**:
```lua
M("n", "<leader>my", function() ... end)
```

### 2. Use Appropriate Modes

✅ **Do**:
```lua
-- Normal and Visual
M({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, { desc = "Code actions" })
```

❌ **Don't**:
```lua
-- Only normal (won't work in visual)
M("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Code actions" })
```

### 3. Group Related Keymaps

✅ **Do**:
```lua
-- All Git operations under <leader>g
M("n", "<leader>gb", ..., { desc = "Git blame" })
M("n", "<leader>gd", ..., { desc = "Git diff" })
M("n", "<leader>gs", ..., { desc = "Git stage" })
```

❌ **Don't**:
```lua
-- Scattered random keys
M("n", "<leader>b", ..., { desc = "Git blame" })
M("n", "<leader>d", ..., { desc = "Git diff" })
M("n", "<F5>", ..., { desc = "Git stage" })
```

### 4. Use FileType Autocmds for Language-Specific Maps

✅ **Do**:
```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    M("n", "<leader>pr", ...)
  end,
})
```

❌ **Don't**:
```lua
-- Global mapping (pollutes namespace)
M("n", "<leader>pr", ...)
```

### 5. Lazy-Load Plugin Keymaps

✅ **Do**:
```lua
{
  "author/plugin",
  keys = {
    { "<leader>p", function() ... end, desc = "Plugin action" },
  },
}
```

❌ **Don't**:
```lua
{
  "author/plugin",
  config = function()
    vim.keymap.set("n", "<leader>p", ...)
  end,
}
```

### 6. Delete Conflicting Mappings Explicitly

✅ **Do**:
```lua
del("n", "<leader>ch")  -- Explicitly delete
M("n", "<leader>ch", ...)  -- Then remap
```

❌ **Don't**:
```lua
-- Just remap and hope for the best
M("n", "<leader>ch", ...)
```

### 7. Use M() Helper for Consistency

✅ **Do**:
```lua
M("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
```

❌ **Don't**:
```lua
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { noremap = true, silent = true, desc = "Quit" })
```

### 8. Document Complex Keymaps

✅ **Do**:
```lua
-- Toggle inlay hints for current buffer
M("n", "<leader>lh", function()
  local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
  vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
end, { desc = "Toggle inlay hints" })
```

### 9. Use Buffer-Local Maps for Buffer-Specific Actions

✅ **Do**:
```lua
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    M("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
  end,
})
```

### 10. Follow Vim Conventions

✅ **Do**:
- Use `]` for next, `[` for previous
- Use `g` prefix for go-to operations
- Use `<leader>` for custom actions
- Use `<C-{key}>` for window/buffer operations

## Quick Reference: Key Prefixes

```lua
-- Navigation
g{key}          -- Go to (gd, gD, gi, gr, etc.)
]{key}          -- Next (]g, ]d, ]c, etc.)
[{key}          -- Previous ([g, [d, [c, etc.)

-- Leader groups
<leader>b       -- Buffer operations
<leader>d       -- Debugger (DAP)
<leader>f       -- Find (Telescope)
<leader>g       -- Git
<leader>l       -- LSP
<leader>o       -- Obsidian
<leader>r       -- Rust-specific
<leader>t       -- Terminal/Testing
<leader>w       -- Window operations

-- Control keys
<C-{key}>       -- Terminal emulators, window navigation
<M-{key}>       -- Alt/Meta, used for mini.move (hjkl)
<C-w>{key}      -- Window operations (Vim default)

-- Special
;               -- Command mode (remapped from :)
Q               -- Disabled (Ex mode)
```

## Common Keymap Patterns

### Pattern: Toggle Function

```lua
M("n", "<leader>tw", function()
  vim.wo.wrap = not vim.wo.wrap
end, { desc = "Toggle line wrap" })
```

### Pattern: Conditional Keymap

```lua
M("n", "<leader>lf", function()
  if vim.bo.filetype == "rust" then
    vim.cmd.RustFmt()
  else
    require("conform").format()
  end
end, { desc = "Format buffer" })
```

### Pattern: Keymap with Arguments

```lua
M("n", "<leader>gs", ":Git stash ", { desc = "Git stash", silent = false })
-- User can type arguments after pressing the key
```

### Pattern: Repeatable with dot

```lua
-- Use vim.cmd for repeatability
M("n", "<leader>i", "<cmd>normal! A;<Esc><cr>", { desc = "Append semicolon" })
```

### Pattern: Multi-step Keymap

```lua
M("n", "<leader>fr", function()
  vim.ui.input({ prompt = "Find and replace: " }, function(input)
    if input then
      vim.cmd("%s/" .. input .. "//g")
    end
  end)
end, { desc = "Find and replace" })
```

## Keymap Debugging Checklist

When a keymap isn't working:

- [ ] `:map <key>` - Does the mapping exist?
- [ ] `:verbose map <key>` - Where is it defined?
- [ ] Check correct mode (n/v/i/etc.)
- [ ] `:Lazy` - Is plugin loaded?
- [ ] `:LspInfo` - Is LSP attached (for LSP keymaps)?
- [ ] Check `desc` field - Does it show in which-key?
- [ ] Test in minimal config - Does it work without other plugins?
- [ ] Check autocmd fired - `:autocmd {event}` (for FileType/LspAttach maps)
- [ ] Check for conflicts - `:verbose map <key>` shows conflicts
- [ ] Restart nvim - Has the mapping been loaded?

## Related Documentation

- **AGENT_LANGUAGE.md** - For language-specific keymaps and commands
- **AGENT_DEBUGGING.md** - For DAP keymaps (`<leader>d*`)
- **AGENTS.md** - For general NvChad architecture

## File Locations Quick Reference

```
lua/mappings.lua                      # All custom keymaps (466 lines)
  Line 1-10:    Helper functions (M, del, default_opts)
  Line 15-33:   Basic navigation & editing
  Line 50-54:   Buffer management
  Line 56-80:   Mini.move (Alt+hjkl)
  Line 82-84:   Terminals
  Line 89-158:  LSP (LspAttach autocmd)
  Line 160-168: Obsidian
  Line 170-218: Git (Gitsigns)
  Line 220-300: Rust (FileType autocmd)

lua/plugins/{plugin}.lua              # Plugin-specific keys
  keys = { ... }                      # Lazy-loaded keymaps
```

## Summary

Keybindings in this config follow a structured approach:

1. **Global mappings** in `lua/mappings.lua` using `M()` helper
2. **Plugin mappings** in plugin specs via `keys = {...}`
3. **LSP mappings** via `LspAttach` autocmd
4. **Language mappings** via `FileType` autocmd
5. **Leader key** (`<space>`) with organized hierarchy
6. **Which-key integration** via `desc` field
7. **Conflict resolution** via `del()` function

Always:
- Include `desc` for which-key
- Use appropriate mode(s)
- Check for conflicts
- Follow Vim conventions
- Group related keymaps under same prefix
- Lazy-load when possible
- Test incrementally
