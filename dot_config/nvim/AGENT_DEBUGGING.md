# Debugging Agent - NvChad Config

**Role**: Specialist agent for configuring, troubleshooting, and managing nvim-dap debugging setups.

---

## Prerequisites

Before performing any debugging tasks, review these resources:
- `lua/plugins/nvim-dap.lua` - Main DAP configuration
- `lua/plugins/nvim-dap-ui.lua` - Debug UI setup
- `lua/configs/mason-nvim-dap.lua` - Debug adapter management
- Base guidelines in `AGENTS.md`

---

## Debug Adapter Architecture

### Current Setup
This config uses nvim-dap with the following components:

**Installed Debug Adapters** (via Mason):
- `js-debug-adapter` - JavaScript/TypeScript/Node.js
- `debugpy` - Python
- `delve` - Go
- `codelldb` - Rust
- `cppdbg` - C/C++

**Language-Specific Plugins**:
- `leoluz/nvim-dap-go` - Go debugging helpers
- `mfussenegger/nvim-dap-python` - Python debugging helpers
- `nvim-dap-vscode-js` (local plugin) - JavaScript/TypeScript debugging

**UI Components**:
- `rcarriga/nvim-dap-ui` - Debug UI with scopes/watches/console
- `theHamsta/nvim-dap-virtual-text` - Inline variable values during debugging
- `jbyuki/one-small-step-for-vimkind` - Lua debugging (for config development)

---

## Debugging Workflow

### Starting a Debug Session

1. **Set breakpoints**: `<leader>db` in normal mode on target line
2. **Start debugging**: `<leader>dc` (continue/run)
3. **DAP UI auto-opens** via listeners in `nvim-dap-ui.lua:57-65`
4. **Use stepping commands**:
   - `<leader>di` - Step into function
   - `<leader>do` - Step out of function
   - `<leader>dO` - Step over line
   - `<leader>dc` - Continue to next breakpoint

### Debug Session Management

**Keybindings** (defined in `nvim-dap.lua:25-58`):
```lua
<leader>db  - Toggle breakpoint
<leader>dB  - Conditional breakpoint (prompts for condition)
<leader>dc  - Continue/Run
<leader>dC  - Run to cursor
<leader>ds  - Stop/terminate session
<leader>dp  - Pause execution

-- Stepping
<leader>di  - Step into
<leader>do  - Step out
<leader>dO  - Step over
<leader>dj  - Down stack frame
<leader>dk  - Up stack frame

-- Inspection
<leader>dr  - Toggle REPL
<leader>dh  - Hover variable (shows value)
<leader>de  - Eval expression (normal/visual mode)
<leader>dv  - Preview variable
<leader>df  - Show frames widget

-- Management
<leader>dx  - Clear all breakpoints
<leader>du  - Toggle DAP UI
<leader>dl  - Run last debug configuration
```

---

## Language-Specific Configurations

### JavaScript/TypeScript/Node.js

**Configurations** (in `nvim-dap.lua:97-149`):
1. **Launch file** - Debug current Node.js file
2. **Attach** - Attach to running Node process (requires `--inspect`)
3. **Launch Chrome** - Debug web app in Chrome
4. **VS Code launch.json** - Load configs from `.vscode/launch.json`

**Common Issues**:
- **"Cannot find runtime 'node'"**: Ensure Node.js is in PATH
- **"Timeout waiting for debugger"**: Check if port 9229 is available
- **Source maps not working**: Verify `sourceMaps: true` in tsconfig.json

**Testing**:
```bash
# Create test file
echo "console.log('Hello debug')" > test.js
nvim test.js
# Set breakpoint on line 1, press <leader>dc
```

### Python

**Setup** (in `nvim-dap.lua:66-74`):
- Uses `debugpy` from Mason
- Falls back to system `python3` if Mason version unavailable
- Auto-configured via `dap-python.setup()`

**Common Issues**:
- **"debugpy not found"**: Run `:MasonInstall debugpy`
- **Wrong Python interpreter**: Check `python_path` in config
- **Virtual env issues**: Ensure debugpy installed in venv

**Testing**:
```bash
echo "print('Hello debug')" > test.py
nvim test.py
# Set breakpoint, press <leader>dc, select "Python: Current File"
```

### Go

**Setup**: Handled by `dap-go` plugin with `delve` debugger

**Common Issues**:
- **"dlv not found"**: Run `:MasonInstall delve`
- **"could not launch process"**: Ensure Go module initialized (`go mod init`)
- **Breakpoint not hit**: Check if file is compiled with `-gcflags "all=-N -l"`

**Testing**:
```go
// test.go
package main
func main() {
    println("Hello debug")
}
```

### Rust

**Setup**: Uses `codelldb` adapter (auto-configured if rustaceanvim plugin enabled)

**Common Issues**:
- **"codelldb not found"**: Run `:MasonInstall codelldb`
- **Binary not found**: Run `cargo build` first
- **Source mapping issues**: Ensure debug symbols enabled in Cargo.toml

### Lua (Neovim Config Debugging)

**Setup**: Uses `one-small-step-for-vimkind` plugin

**Usage**:
```lua
-- Add to code to debug
require("osv").launch({ port = 8086 })
```
Then attach debugger via DAP menu

---

## Troubleshooting Guide

### General Debug Issues

#### Problem: DAP UI doesn't open
**Diagnosis**:
```vim
:lua print(vim.inspect(require('dap').listeners))
```

**Solution**:
- Check `nvim-dap-ui.lua:57-65` listeners are configured
- Verify nvim-nio dependency installed: `:Lazy load nvim-nio`
- Restart Neovim

#### Problem: Breakpoints not stopping execution
**Diagnosis**:
1. Check if breakpoint is verified (should show different icon when hit)
2. Run `:lua print(vim.inspect(require('dap').breakpoints()))`
3. Check DAP REPL for errors: `<leader>dr`

**Solutions**:
- Ensure debug adapter is running: `:lua print(vim.inspect(require('dap').status()))`
- Verify source maps enabled (JS/TS)
- Check file path matches compiled output
- For compiled languages: rebuild with debug symbols

#### Problem: "No configuration found"
**Solutions**:
1. Create `.vscode/launch.json` in project root
2. Or select from available configs: `:lua require('dap').continue()` (shows picker)
3. Or define custom config in `nvim-dap.lua`

#### Problem: Variables show "Not Available"
**Diagnosis**:
- Check if optimizer removed variables (common in release builds)
- Verify you're stopped at correct stack frame

**Solutions**:
- For Rust: Use debug profile in Cargo.toml
- For Go: Use `-gcflags "all=-N -l"` to disable optimizations
- For C/C++: Compile with `-g -O0`

### Debug Adapter Issues

#### Check adapter status:
```vim
:lua print(vim.inspect(require('dap').adapters))
```

#### Check configurations:
```vim
:lua print(vim.inspect(require('dap').configurations))
```

#### Enable DAP logging:
```lua
-- Add to nvim-dap.lua config
require('dap').set_log_level('TRACE')
-- View logs
vim.cmd('edit ' .. vim.fn.stdpath('cache') .. '/dap.log')
```

### Mason Debug Adapter Management

**List installed adapters**:
```vim
:Mason
# Filter by "DAP" category
```

**Install/update adapter**:
```vim
:MasonInstall debugpy
:MasonUpdate debugpy
```

**Check adapter path**:
```bash
ls ~/.local/share/nvim/mason/bin/
```

---

## Adding New Debug Adapters

### Workflow

1. **Research adapter** - Check nvim-dap wiki: https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
2. **Add to Mason** - Edit `lua/configs/mason-nvim-dap.lua`:
   ```lua
   ensure_installed = {
     "new-adapter-name",
   }
   ```
3. **Configure adapter** - In `lua/plugins/nvim-dap.lua` config function:
   ```lua
   local dap = require('dap')
   dap.adapters.adapter_name = {
     type = 'executable',
     command = 'adapter-executable',
     args = { 'arg1', 'arg2' }
   }
   ```
4. **Add configurations** - Define launch configs:
   ```lua
   dap.configurations.filetype = {
     {
       type = 'adapter_name',
       request = 'launch',
       name = 'Launch Program',
       program = '${file}',
     }
   }
   ```
5. **Test** - Create sample file, set breakpoint, run `:lua require('dap').continue()`
6. **Document** - Add to this file in "Language-Specific Configurations"

### Example: Adding Ruby Debugging

```lua
-- In mason-nvim-dap.lua
ensure_installed = {
  "ruby-debug-adapter",  -- Add this
}

-- In nvim-dap.lua config function
local dap = require('dap')

-- Adapter configuration
dap.adapters.ruby = {
  type = 'executable',
  command = 'bundle',
  args = { 'exec', 'rdbg', '-n', '--open', '--port', '38698', '-c', '--', 'bundle', 'exec' }
}

-- Launch configurations
dap.configurations.ruby = {
  {
    type = 'ruby',
    request = 'launch',
    name = 'Debug Ruby file',
    program = '${file}',
  },
  {
    type = 'ruby',
    request = 'attach',
    name = 'Attach to rdbg',
    port = 38698,
  }
}
```

---

## Advanced Features

### Conditional Breakpoints

Use `<leader>dB` to set breakpoint with condition:
```
Example conditions:
- i > 10
- name == "test"
- response.status != 200
```

### Logpoints

Set breakpoint that logs without stopping:
```lua
require('dap').set_breakpoint(nil, nil, 'Log message: {variable}')
```

### Custom Configurations per Project

Create `.vscode/launch.json` in project root:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "pwa-node",
      "request": "launch",
      "name": "Debug API Server",
      "program": "${workspaceFolder}/src/server.js",
      "env": {
        "NODE_ENV": "development"
      }
    }
  ]
}
```

Config is auto-loaded via `vscode.json_decode` in `nvim-dap.lua:152-156`

### DAP Extensions

**Test debugging**: Use with neotest plugin
```lua
-- Run test under cursor with debugger
require('neotest').run.run({strategy = 'dap'})
```

**Remote debugging**: Attach to remote process
```lua
dap.configurations.python = {
  {
    type = 'python',
    request = 'attach',
    name = 'Attach remote',
    connect = {
      host = '192.168.1.100',
      port = 5678,
    },
  }
}
```

---

## Performance Considerations

### DAP UI Impact
- Auto-open/close listeners in `nvim-dap-ui.lua:57-65` can cause lag on slow machines
- To disable auto-open: Comment out listeners
- Manual toggle: `<leader>du`

### Virtual Text
- `nvim-dap-virtual-text` shows inline values during debug
- Can be slow with large data structures
- Disable if needed: Set `enabled = false` in plugin spec

---

## Common Tasks

### Task: Enable debug mode for specific file type
1. Check if adapter installed: `:Mason`
2. Verify config exists: `:lua print(vim.inspect(require('dap').configurations.filetype))`
3. If missing, add configuration following "Adding New Debug Adapters" section

### Task: Debug isn't stopping at breakpoints
1. Check breakpoint is set: `:lua print(vim.inspect(require('dap').breakpoints()))`
2. Verify source path matches: Check DAP REPL output
3. Enable logging: `require('dap').set_log_level('TRACE')`
4. Check log: `:edit ~/.local/share/nvim/dap.log`

### Task: Update all debug adapters
1. Backup lock file: `cp lazy-lock.json lazy-lock.json.backup`
2. Update Mason packages: `:MasonUpdate`
3. Test a debug session: Open sample file, set breakpoint, run
4. If issues: Rollback with `:MasonInstall debugpy@1.2.3` (specific version)

### Task: Clean up debug configurations
1. Review active configs: `:lua print(vim.inspect(require('dap').configurations))`
2. Edit `lua/plugins/nvim-dap.lua` to remove unused configs
3. Format: `stylua lua/plugins/nvim-dap.lua`
4. Test remaining configs still work

---

## Integration with Other Plugins

### Telescope Integration
```lua
-- In lua/mappings.lua
{ "<leader>dT", "<cmd>Telescope dap commands<cr>", desc = "DAP Commands" }
{ "<leader>dt", "<cmd>Telescope dap configurations<cr>", desc = "DAP Configs" }
```

### Which-key Integration
Debug keybindings auto-register with which-key via `desc` fields in keymaps

### Neotest Integration
```lua
-- Run with debugger (already configured in this config)
require('neotest').run.run({strategy = 'dap'})
```

---

## Best Practices

1. **Always set breakpoint before running** - Don't rely on stopping at start
2. **Use conditional breakpoints** - Avoid hitting breakpoint 100 times in loop
3. **Check DAP REPL** - Most errors appear there: `<leader>dr`
4. **Use launch.json for complex setups** - Don't hardcode in config
5. **Test after Mason updates** - Debug adapters can break between versions
6. **Enable logging when troubleshooting** - `set_log_level('TRACE')` is your friend
7. **One adapter per language** - Don't install multiple JS debuggers (causes conflicts)

---

## Quick Reference

### Keymap Cheatsheet
```
BREAKPOINTS:          STEPPING:             INSPECTION:
<leader>db - Toggle   <leader>di - Into     <leader>dh - Hover
<leader>dB - Cond     <leader>do - Out      <leader>de - Eval
<leader>dx - Clear    <leader>dO - Over     <leader>dv - Preview
                      <leader>dj - Down     <leader>df - Frames
CONTROL:              <leader>dk - Up       <leader>dr - REPL
<leader>dc - Run                            <leader>du - Toggle UI
<leader>ds - Stop     
<leader>dp - Pause    
<leader>dl - Last     
```

### Files to Edit
- **Add adapter**: `lua/configs/mason-nvim-dap.lua`
- **Configure adapter**: `lua/plugins/nvim-dap.lua`
- **Customize UI**: `lua/plugins/nvim-dap-ui.lua`
- **Add keymaps**: `lua/plugins/nvim-dap.lua` (keys table)

### Diagnostic Commands
```vim
:lua print(vim.inspect(require('dap').adapters))      " List adapters
:lua print(vim.inspect(require('dap').configurations)) " List configs
:lua print(vim.inspect(require('dap').breakpoints())) " List breakpoints
:lua print(require('dap').status())                   " Check status
:lua require('dap').set_log_level('TRACE')            " Enable logging
:edit ~/.local/share/nvim/dap.log                     " View logs
```

---

## Emergency Procedures

### Debug session frozen
1. Force stop: `:lua require('dap').terminate()`
2. If unresponsive: `:lua require('dap').close()`
3. Nuclear option: `:qa!` and restart

### DAP completely broken
1. Check health: `:checkhealth dap`
2. Reinstall adapters: `:MasonUninstall debugpy && :MasonInstall debugpy`
3. Clear DAP state: `rm -rf ~/.local/state/nvim/dap.log`
4. Restart Neovim

### Rollback after bad update
1. Restore lock file: `cp lazy-lock.json.backup lazy-lock.json`
2. Sync plugins: `:Lazy restore`
3. Update only DAP: `:Lazy update nvim-dap`

---

**Remember**: When in doubt, check the DAP log first. Most issues are adapter path or configuration problems visible in logs.
