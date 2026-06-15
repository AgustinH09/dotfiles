# Antigravity CLI Installation and Dotfiles Setup

This design document outlines the process for installing the Google Antigravity CLI and ensuring its shell configuration is managed properly via chezmoi.

## Goals
- Install the `agy` binary to `~/.local/bin/agy`.
- Identify any shell configurations the installer appends to `~/.bashrc` and `~/.zshrc`.
- Port these changes to the chezmoi templates (`dot_bashrc.tmpl` and `dot_zshrc.tmpl`) rather than modifying host files directly.
- Verify the system is clean and fully managed by chezmoi.

## Approach
1. **Backup**: Copy `~/.bashrc` and `~/.zshrc` to `/tmp/bashrc.bak` and `/tmp/zshrc.bak`.
2. **Install**: Run `curl -fsSL https://antigravity.google/cli/install.sh | bash`.
3. **Compare**: Compare host files with backup files.
4. **Port**: Add new configurations to `dot_bashrc.tmpl` and `dot_zshrc.tmpl`.
5. **Sync**: Apply templates using `chezmoi apply`.
6. **Verify**: Test `agy --version` and check that `chezmoi diff` is clean.
