# Language Configuration Specialist Agent

This agent specializes in adding, configuring, and troubleshooting language-specific support in the NvChad configuration. It handles LSP servers, treesitter parsers, formatters, linters, and debug adapters for programming languages.

## When to Use This Agent

Use this agent when:
- Adding support for a new programming language
- Troubleshooting language-specific features (LSP, formatting, linting)
- Configuring language-specific settings (tabs, errorformat, autocmds)
- Setting up language-specific commands and utilities
- Debugging language server issues
- Optimizing language-specific performance

## Project Structure for Language Support

```
lua/
  configs/
    {language}.lua           # Language-specific config (go.lua, rust.lua, ruby.lua)
    lspconfig.lua            # LSP server configurations
    treesitter.lua           # Treesitter parser setup
    conform.lua              # Formatter configuration
    lint.lua                 # Linter configuration
    mason-lspconfig.lua      # Mason LSP coordination
    mason-conform.lua        # Mason formatter coordination
    mason-lint.lua           # Mason linter coordination
    mason-nvim-dap.lua       # Mason DAP adapter coordination
  plugins/
    rustaceanvim.lua         # Language-specific plugins (e.g., Rust)
    gopher.lua               # Language-specific plugins (e.g., Go)
  chadrc.lua                 # Mason package list
```

## Configuration Architecture

### 1. Mason Package Management (Central Registry)

**File**: `lua/chadrc.lua`

All tools are declared in a central `M.mason.pkgs` table:

```lua
M.mason = {
  pkgs = {
    -- LSP servers
    "lua-language-server",
    "typescript-language-server",
    "gopls",
    "ruby-lsp",
    "rust-analyzer",
    
    -- Formatters
    "prettier",
    "stylua",
    "gofumpt",
    "rubocop",
    
    -- Linters
    "golangci-lint",
    "eslint_d",
    
    -- DAP adapters
    "debugpy",
    "delve",
    "codelldb",
  },
}
```

### 2. LSP Configuration

**File**: `lua/configs/lspconfig.lua`

LSP servers are configured in a `servers` table with setup options:

```lua
local servers = {
  -- Simple default config
  gopls = {},
  
  -- With custom settings
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { enable = false },
        workspace = { library = {...} },
      },
    },
  },
  
  -- With custom on_attach
  ruby_lsp = {
    on_attach = function(client, bufnr)
      client.server_capabilities.documentFormattingProvider = false
      on_attach(client, bufnr)
    end,
    init_options = {
      formatter = "rubocop",
      linters = { "rubocop" },
    },
  },
}
```

**Important patterns**:
- Disable LSP formatting if using external formatters: `client.server_capabilities.documentFormattingProvider = false`
- Use `on_attach` wrapper to remove NvChad keymaps: see line 68-80
- Enable inlay hints: `vim.lsp.inlay_hint.enable(true, { buffer = bufnr })`

### 3. Treesitter Configuration

**File**: `lua/configs/treesitter.lua`

Add parsers to `ensure_installed` list:

```lua
local options = {
  ensure_installed = {
    "go", "gomod", "gosum", "gowork",  -- Go ecosystem
    "rust",                             -- Rust
    "ruby",                             -- Ruby
    "javascript", "typescript", "tsx",  -- JS/TS ecosystem
    "lua", "luadoc",                    -- Lua
  },
}
```

### 4. Formatter Configuration

**File**: `lua/configs/conform.lua`

Define formatters per filetype:

```lua
local formatters_by_ft = {
  lua = { "stylua" },
  go = { "gofumpt", "goimports-reviser", "golines" },
  rust = { "rustfmt" },
  ruby = { "rubocop" },
  javascript = { "prettier", "eslint_d" },
}
```

Custom formatter options:

```lua
formatters = {
  ["goimports-reviser"] = {
    prepend_args = { "-rm-unused" },
  },
  rubocop = {
    args = { "--server", "--auto-correct-all", "--stderr", "--stdin", "$FILENAME" },
  },
}
```

### 5. Linter Configuration

**File**: `lua/configs/lint.lua`

Define linters per filetype:

```lua
lint.linters_by_ft = {
  lua = { "luacheck" },
  go = { "golangcilint" },
  rust = { "clippy" },
  ruby = { "rubocop" },
  javascript = { "eslint_d" },
}
```

Custom linter args:

```lua
local luacheck_args = lint.linters.luacheck.args or {}
vim.list_extend(luacheck_args, { "--globals", "vim" })
lint.linters.luacheck.args = luacheck_args
```

### 6. Language-Specific Config Files

**Pattern**: Create `lua/configs/{language}.lua` for language-specific setup.

**Template Structure**:

```lua
-- {Language}-specific configuration and utilities

local M = {}

M.setup = function()
  -- FileType autocmd for settings
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "{language}",
    callback = function()
      -- Tab settings
      vim.bo.expandtab = true
      vim.bo.tabstop = 4
      vim.bo.shiftwidth = 4
      
      -- Errorformat
      vim.bo.errorformat = "..."
      
      -- Other options
      vim.opt_local.foldmethod = "syntax"
    end,
  })
  
  -- BufWritePre autocmd for pre-save actions
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.{ext}",
    callback = function()
      -- Auto-organize imports, etc.
    end,
  })
  
  -- BufNewFile autocmd for templates
  vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = "{file_pattern}",
    callback = function()
      -- Insert template code
    end,
  })
  
  -- User commands
  vim.api.nvim_create_user_command("MyCommand", function(opts)
    -- Command implementation
  end, { 
    nargs = "+", 
    desc = "Description",
    complete = function() return {...} end,
  })
end

-- Call setup
M.setup()

return M
```

## Adding Support for a New Language

### Step 1: Identify Required Tools

Determine what you need:
- **LSP Server**: Language intelligence (completion, diagnostics, go-to-definition)
- **Treesitter Parser**: Syntax highlighting and code understanding
- **Formatter**: Code formatting tool
- **Linter**: Code quality/style checker
- **DAP Adapter**: Debugger (optional)

### Step 2: Add Mason Packages

**File**: `lua/chadrc.lua`

Add packages to `M.mason.pkgs`:

```lua
M.mason = {
  pkgs = {
    -- LSP
    "python-lsp-server",  -- or "pyright"
    
    -- Formatters
    "black",
    "isort",
    
    -- Linters
    "ruff",
    
    -- DAP
    "debugpy",
  },
}
```

**Finding package names**: `:Mason` → search → note exact name

### Step 3: Configure LSP

**File**: `lua/configs/lspconfig.lua`

Add to `servers` table:

```lua
local servers = {
  -- Existing servers...
  
  pyright = {
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "basic",
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
        },
      },
    },
  },
}
```

### Step 4: Add Treesitter Parser

**File**: `lua/configs/treesitter.lua`

Add to `ensure_installed`:

```lua
ensure_installed = {
  -- Existing parsers...
  "python",
}
```

### Step 5: Configure Formatter

**File**: `lua/configs/conform.lua`

Add to `formatters_by_ft`:

```lua
local formatters_by_ft = {
  -- Existing...
  python = { "black", "isort" },
}
```

Optional custom config:

```lua
formatters = {
  black = {
    prepend_args = { "--line-length", "100" },
  },
}
```

### Step 6: Configure Linter

**File**: `lua/configs/lint.lua`

Add to `lint.linters_by_ft`:

```lua
lint.linters_by_ft = {
  -- Existing...
  python = { "ruff" },
}
```

### Step 7: Create Language Config File (Optional)

**File**: `lua/configs/python.lua`

```lua
local M = {}

M.setup = function()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
      vim.bo.tabstop = 4
      vim.bo.shiftwidth = 4
      vim.bo.expandtab = true
    end,
  })
  
  -- Python REPL
  vim.api.nvim_create_user_command("PythonRepl", function()
    vim.cmd("terminal python")
  end, { desc = "Open Python REPL" })
end

M.setup()
return M
```

**Load the config**: Add to `lua/configs/lazy.lua` or your init:

```lua
require "configs.python"
```

### Step 8: Install and Test

```bash
# Start Neovim
nvim

# Install Mason packages
:MasonInstallAll

# Test LSP
:LspInfo

# Test formatters
:ConformInfo

# Test linter
:Lint

# Open a test file
:e test.py
```

## Language-Specific Patterns

### Go Configuration Example

**Key features**: Auto-organize imports, alternate between test/impl, workspace commands

```lua
-- Auto-organize imports on save using gopls
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
  end,
})

-- Alternate between test and implementation
vim.api.nvim_create_user_command("GoAlternate", function()
  local file = vim.fn.expand("%:p")
  local alt_file = file:match("_test%.go$") 
    and file:gsub("_test%.go$", ".go")
    or file:gsub("%.go$", "_test.go")
  
  if vim.fn.filereadable(alt_file) == 1 then
    vim.cmd("edit " .. alt_file)
  else
    vim.notify("Alternate file not found", vim.log.levels.WARN)
  end
end, { desc = "Switch between Go file and its test" })

-- Tab settings
vim.bo.expandtab = false
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4
```

**Reference**: `lua/configs/go.lua:6-72`

### Rust Configuration Example

**Key features**: Cargo commands, crate search, documentation shortcuts

```lua
-- Cargo command wrapper
vim.api.nvim_create_user_command("Cargo", function(opts)
  local cmd = "cargo " .. opts.args
  
  -- Run in terminal for interactive commands
  if opts.args:match("^run") or opts.args:match("^test") then
    vim.cmd("split | terminal " .. cmd)
  else
    vim.fn.jobstart(cmd, {
      on_stdout = function(_, data)
        if data[1] ~= "" then vim.notify(table.concat(data, "\n")) end
      end,
    })
  end
end, {
  nargs = "+",
  complete = function(arglead)
    local cmds = { "build", "run", "test", "check", "clippy", "fmt" }
    return vim.tbl_filter(function(cmd)
      return cmd:match("^" .. arglead)
    end, cmds)
  end,
})

-- Auto-create main.rs template
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "main.rs",
  callback = function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      "fn main() {",
      '    println!("Hello, world!");',
      "}",
    })
    vim.fn.cursor(2, 5)
  end,
})
```

**Reference**: `lua/configs/rust.lua:5-145`

### Ruby Configuration Example

**Key features**: Bundle integration, RuboCop, frozen_string_literal

```lua
-- Bundle commands
vim.api.nvim_create_user_command("Bundle", function(opts)
  local cmd = "bundle " .. opts.args
  vim.fn.jobstart(cmd, {
    on_stdout = function(_, data)
      if data[1] ~= "" then vim.notify(table.concat(data, "\n")) end
    end,
  })
end, {
  nargs = "+",
  complete = function()
    return { "install", "update", "exec", "add", "outdated" }
  end,
})

-- Auto-insert frozen string literal
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.rb",
  callback = function()
    if vim.fn.getline(1) == "" then
      vim.fn.setline(1, "# frozen_string_literal: true")
      vim.fn.append(1, "")
      vim.fn.cursor(3, 1)
    end
  end,
})
```

**Reference**: `lua/configs/ruby.lua:5-92`

### Markdown Configuration Example

**Key features**: Performance optimization for large files

```lua
-- Detect large files and disable expensive features
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  pattern = { "*.md", "*.markdown" },
  callback = function(args)
    local ok, stats = pcall(vim.loop.fs_stat, args.file)
    if ok and stats and stats.size / 1024 > 100 then
      vim.notify("Large markdown file. Disabling features for performance.")
      vim.cmd("TSBufDisable highlight")
      vim.opt_local.spell = false
      vim.opt_local.cursorline = false
      
      -- Detach LSP for performance
      vim.schedule(function()
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
          vim.lsp.buf_detach_client(args.buf, client.id)
        end
      end)
    end
  end,
})
```

**Reference**: `lua/configs/markdown.lua:8-79`

## Troubleshooting Language Issues

### Issue: LSP Not Attaching

**Symptoms**: No completion, diagnostics, or LSP features

**Debug steps**:

1. Check LSP status:
   ```vim
   :LspInfo
   ```
   Should show attached client(s)

2. Check if server is running:
   ```vim
   :LspLog
   ```
   Look for startup errors

3. Check Mason installation:
   ```vim
   :Mason
   ```
   Verify server is installed (green checkmark)

4. Check server configuration:
   - Look in `lua/configs/lspconfig.lua` for server entry
   - Verify `servers` table has the server name
   - Check for typos in server name

5. Check filetype detection:
   ```vim
   :set filetype?
   ```
   Should match LSP server filetype

**Common fixes**:

```lua
-- Explicitly set root_dir if LSP doesn't auto-detect project
markdown_oxide = {
  root_dir = util.root_pattern(".obsidian", ".git", "README.md"),
}

-- Check if server needs specific command
ruby_lsp = {
  cmd = { "mise", "exec", "--", "ruby-lsp" },  -- Use mise wrapper
}

-- Verify capabilities are set correctly
markdown_oxide = {
  capabilities = vim.tbl_deep_extend("force", capabilities, {
    workspace = {
      didChangeWatchedFiles = { dynamicRegistration = true },
    },
  }),
}
```

**Reference**: `lua/configs/lspconfig.lua:193-204`

### Issue: Formatter Not Working

**Symptoms**: `:Format` doesn't format or formats incorrectly

**Debug steps**:

1. Check formatter status:
   ```vim
   :ConformInfo
   ```
   Should show available formatters for current filetype

2. Verify Mason installation:
   ```vim
   :Mason
   ```
   Check if formatter is installed

3. Check formatter configuration:
   - `lua/configs/conform.lua` → `formatters_by_ft`
   - Verify filetype matches exactly

4. Test manually:
   ```bash
   # From shell
   prettier --version
   stylua --version
   ```

**Common fixes**:

```lua
-- Add filetype if missing
formatters_by_ft = {
  python = { "black", "isort" },  -- Add this line
}

-- Fix formatter args
formatters = {
  rubocop = {
    args = { "--server", "--auto-correct-all", "--stdin", "$FILENAME" },
  },
}

-- Conditional formatter (only if config exists)
eslint_d = {
  condition = function(ctx)
    return vim.fs.find({".eslintrc"}, {path = ctx.filename, upward = true})[1]
  end,
}
```

**Reference**: `lua/configs/conform.lua:40-52`

### Issue: Linter Not Running

**Symptoms**: No lint diagnostics appearing

**Debug steps**:

1. Check linter configuration:
   ```lua
   :lua print(vim.inspect(require('lint').linters_by_ft))
   ```

2. Verify Mason installation:
   ```vim
   :Mason
   ```

3. Run manually:
   ```vim
   :Lint
   ```

4. Check autocmd is set:
   ```vim
   :autocmd lint
   ```

**Common fixes**:

```lua
-- Add linter for filetype
lint.linters_by_ft = {
  python = { "ruff" },  -- Add this
}

-- Fix linter args
local luacheck_args = lint.linters.luacheck.args or {}
vim.list_extend(luacheck_args, { "--globals", "vim" })
lint.linters.luacheck.args = luacheck_args

-- Custom linter parser
lint.linters.eslint_d = {
  cmd = "eslint_d",
  parser = function(output, bufnr)
    local ok, decoded = pcall(vim.json.decode, output)
    if not ok then return {} end
    -- Custom parsing logic
  end,
}
```

**Reference**: `lua/configs/lint.lua:23-64`

### Issue: Treesitter Syntax Highlighting Wrong

**Symptoms**: Wrong colors, missing highlights

**Debug steps**:

1. Check parser installation:
   ```vim
   :TSInstallInfo
   ```
   Should show parser as installed

2. Check highlighting is enabled:
   ```vim
   :TSBufToggle highlight
   ```

3. Inspect treesitter tree:
   ```vim
   :InspectTree
   ```

4. Check for treesitter errors:
   ```vim
   :checkhealth nvim-treesitter
   ```

**Common fixes**:

```lua
-- Add parser to ensure_installed
ensure_installed = {
  "python",  -- Add this
}

-- Disable for specific filetypes if causing issues
highlight = {
  enable = true,
  disable = { "yaml" },  -- Disable for YAML
}

-- Use additional vim regex highlighting
highlight = {
  enable = true,
  additional_vim_regex_highlighting = { "ruby" },  -- For Ruby
}
```

**Reference**: `lua/configs/treesitter.lua:46-50`

### Issue: Format-on-Save Too Slow

**Symptoms**: Noticeable delay when saving files

**Debug steps**:

1. Check timeout setting:
   ```lua
   -- In conform.lua format_on_save
   return { timeout_ms = 1000 }  -- Current timeout
   ```

2. Profile formatters:
   ```vim
   :ConformInfo
   ```
   Check which formatters are running

3. Measure save time:
   ```vim
   :profile start /tmp/profile.log
   :profile func *
   :profile file *
   " Save file
   :profile stop
   ```

**Common fixes**:

```lua
-- Increase timeout
return { timeout_ms = 2000 }

-- Disable for large files
format_on_save = function(bufnr)
  local max_filesize = 100 * 1024  -- 100 KB
  local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
  if ok and stats and stats.size > max_filesize then
    return
  end
  return { timeout_ms = 1000 }
end

-- Use fewer formatters
python = { "black" },  -- Instead of { "black", "isort", "autopep8" }

-- Disable for specific directories
if bufname:match("/node_modules/") or bufname:match("/vendor/") then
  return
end
```

**Reference**: `lua/configs/conform.lua:55-72`

### Issue: Wrong Tab Settings

**Symptoms**: Mixed tabs/spaces, wrong indentation width

**Debug steps**:

1. Check current settings:
   ```vim
   :set expandtab? tabstop? shiftwidth?
   ```

2. Check if EditorConfig is overriding:
   ```vim
   :EditorConfigReload
   ```

3. Check for language-specific settings:
   - Look in `lua/configs/{language}.lua`
   - Check FileType autocmds

**Common fixes**:

```lua
-- Add to language config file
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.bo.expandtab = true   -- Use spaces
    vim.bo.tabstop = 4        -- Tab display width
    vim.bo.shiftwidth = 4     -- Indent width
    vim.bo.softtabstop = 4    -- Tab key behavior
  end,
})

-- For Go (uses real tabs)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.bo.expandtab = false  -- Use real tabs
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
  end,
})
```

**Reference**: `lua/configs/go.lua:11-14`, `lua/configs/ruby.lua:10-14`

## Language Tool Coordination Table

| Language   | LSP Server          | Formatters                    | Linters         | DAP Adapter      | Treesitter Parsers |
|------------|---------------------|-------------------------------|-----------------|------------------|--------------------|
| Lua        | lua_ls              | stylua                        | luacheck        | -                | lua, luadoc        |
| Go         | gopls               | gofumpt, goimports-reviser    | golangci-lint   | delve            | go, gomod, gosum   |
| Rust       | rust_analyzer       | rustfmt                       | clippy          | codelldb         | rust               |
| Ruby       | ruby_lsp            | rubocop                       | rubocop         | -                | ruby               |
| Python     | pyright             | black, isort                  | ruff            | debugpy          | python             |
| JS/TS      | ts_ls               | prettier, eslint_d            | eslint_d        | js-debug-adapter | javascript, tsx    |
| HTML/CSS   | html, cssls         | prettier                      | -               | -                | html, css          |
| Markdown   | markdown_oxide      | prettier, markdownlint-cli2   | markdownlint    | -                | markdown           |
| Terraform  | terraform_ls        | terraform_fmt                 | tflint, tfsec   | -                | terraform, hcl     |

## Best Practices

### 1. Consistent Package Management

✅ **Do**: Add all tools to `chadrc.lua` first

```lua
-- lua/chadrc.lua
M.mason = {
  pkgs = {
    "gopls",        -- LSP
    "gofumpt",      -- Formatter
    "golangci-lint" -- Linter
  }
}
```

❌ **Don't**: Install packages manually without updating config

### 2. Disable LSP Formatting When Using External Formatters

✅ **Do**: Disable in LSP config to avoid conflicts

```lua
gopls = {
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    on_attach(client, bufnr)
  end,
}
```

❌ **Don't**: Let both LSP and conform.nvim format

### 3. Use Language Config Files for Complex Setup

✅ **Do**: Create dedicated config file for 10+ lines of setup

```lua
-- lua/configs/go.lua
local M = {}
M.setup = function()
  -- FileType settings
  -- Autocmds
  -- Commands
end
M.setup()
return M
```

❌ **Don't**: Put everything in `lspconfig.lua`

### 4. Lazy-Load Language Plugins

✅ **Do**: Load plugins only for specific filetypes

```lua
{
  "ray-x/go.nvim",
  ft = { "go", "gomod" },
  config = function()
    require("go").setup()
  end,
}
```

❌ **Don't**: Load language plugins at startup

### 5. Test Language Setup Incrementally

✅ **Do**: Test each component individually

```bash
1. Add to Mason → :MasonInstallAll
2. Configure LSP → :LspInfo
3. Add formatter → :ConformInfo
4. Add linter → :Lint
```

❌ **Don't**: Configure everything at once then debug

### 6. Handle Large Files Gracefully

✅ **Do**: Disable expensive features for large files

```lua
vim.api.nvim_create_autocmd("BufReadPre", {
  callback = function(args)
    local ok, stats = pcall(vim.loop.fs_stat, args.file)
    if ok and stats and stats.size > 100000 then
      vim.cmd("TSBufDisable highlight")
      vim.bo.swapfile = false
    end
  end,
})
```

❌ **Don't**: Apply all features regardless of file size

### 7. Use Proper Errorformat

✅ **Do**: Set errorformat for better quickfix integration

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.bo.errorformat = vim.bo.errorformat .. ",%f:%l:%c: %m"
  end,
})
```

### 8. Provide Useful Commands

✅ **Do**: Create commands with completion and descriptions

```lua
vim.api.nvim_create_user_command("Cargo", function(opts)
  -- implementation
end, {
  nargs = "+",
  complete = function() return { "build", "test", "run" } end,
  desc = "Run cargo commands",
})
```

❌ **Don't**: Create commands without descriptions

## Testing Checklist for New Language

After adding language support, verify:

- [ ] `:checkhealth mason` - No errors
- [ ] `:Mason` - All packages installed (green checkmarks)
- [ ] `:LspInfo` - LSP attaches to buffer
- [ ] `:ConformInfo` - Formatters available
- [ ] `:Lint` - Linters run without errors
- [ ] `:TSInstallInfo` - Parser installed
- [ ] Open language file - Syntax highlighting works
- [ ] `:lua vim.lsp.buf.hover()` - Documentation popup works
- [ ] Save file - Auto-format works
- [ ] Type invalid code - Diagnostics appear
- [ ] `:Format` - Manual format works
- [ ] Check tab settings - Correct indentation
- [ ] Test language-specific commands (if any)

## Common Language-Specific Commands

### Go
- `:GoAlternate` - Switch between test and implementation
- `:GoWork init` - Initialize go workspace

### Rust
- `:Cargo build` - Build project
- `:Cargo test` - Run tests
- `:RustPlayground` - Open in playground
- `:RustDoc` - Search documentation

### Ruby
- `:Bundle install` - Install gems
- `:RuboCop` - Run rubocop
- `:RubyRepl` - Open irb

### Markdown
- `:MarkdownPerformanceMode` - Disable expensive features
- `:MarkdownDiagnostics` - Show buffer diagnostics

## Performance Considerations

### Language Server Performance

**Slow LSP startup**:
```lua
-- Reduce workspace scanning
lua_ls = {
  settings = {
    Lua = {
      workspace = {
        maxPreload = 10000,      -- Reduce from 100000
        preloadFileSize = 1000,  -- Reduce from 10000
      },
    },
  },
}
```

**Too many diagnostics**:
```lua
-- Limit diagnostic severity
vim.diagnostic.config({
  virtual_text = {
    severity = { min = vim.diagnostic.severity.WARN },  -- Hide hints
  },
})
```

### Formatter Performance

**Slow formatting**:
```lua
-- Increase timeout or use faster formatter
format_on_save = function(bufnr)
  return { timeout_ms = 2000 }  -- Increase from 1000
end

-- Or use faster alternative
python = { "ruff_format" },  -- Instead of "black"
```

### Treesitter Performance

**Slow syntax highlighting**:
```lua
-- Disable for large files
highlight = {
  enable = true,
  disable = function(lang, bufnr)
    return vim.api.nvim_buf_line_count(bufnr) > 5000
  end,
}
```

## Quick Reference Commands

```vim
" Mason
:Mason                  " Open Mason UI
:MasonInstall {pkg}     " Install package
:MasonUninstall {pkg}   " Uninstall package
:MasonInstallAll        " Install all packages from chadrc.lua

" LSP
:LspInfo                " Show LSP client status
:LspLog                 " Show LSP log
:LspRestart             " Restart LSP servers
:LspStart               " Start LSP server

" Treesitter
:TSInstall {lang}       " Install parser
:TSUpdate               " Update all parsers
:TSInstallInfo          " Show installation status
:TSBufToggle highlight  " Toggle highlighting
:InspectTree            " Show syntax tree

" Formatting
:Format                 " Format current buffer
:ConformInfo            " Show formatter status

" Linting
:Lint                   " Run linters manually

" Diagnostics
:MasonDiagnostics       " Mason troubleshooting
:MarkdownDiagnostics    " Markdown-specific diagnostics
```

## Related Documentation

- **AGENT_DEBUGGING.md** - For DAP adapter configuration
- **AGENT_PERFORMANCE.md** - For startup time and runtime optimization
- **AGENT_MAINTENANCE.md** - For updating language tools
- **AGENTS.md** - For general build/lint/test commands

## File Locations Quick Reference

```
lua/
  configs/
    lspconfig.lua           # LSP servers (line 87-205)
    treesitter.lua          # Parsers (line 2-41)
    conform.lua             # Formatters (line 5-22, 33-53)
    lint.lua                # Linters (line 3-21)
    go.lua                  # Go config
    rust.lua                # Rust config
    ruby.lua                # Ruby config
    markdown.lua            # Markdown config
  chadrc.lua                # Mason packages (line 14-51)
```

## Summary

Language support in this config requires coordination across 5 components:
1. **Mason packages** (`chadrc.lua`) - Install tools
2. **LSP** (`lspconfig.lua`) - Language intelligence
3. **Treesitter** (`treesitter.lua`) - Syntax highlighting
4. **Formatters** (`conform.lua`) - Code formatting
5. **Linters** (`lint.lua`) - Code quality

Optional 6th component:
6. **Language config** (`configs/{lang}.lua`) - Custom settings/commands

Always test incrementally and verify each component works before moving to the next.
