# Dotfiles

Personal dotfiles managed with [Chezmoi](https://www.chezmoi.io/) and secured with [Age](https://github.com/FiloSottile/age) encryption.

## Overview

This repository contains my personal system configuration files for Linux (Fedora/Hyprland). All sensitive data is encrypted using Age, making it safe to share publicly while maintaining security.

## Features

- **Hyprland configuration**: Wayland compositor with custom keybindings and themes
- **Shell configuration**: Zsh with Oh My Zsh, Powerlevel10k, and other tools
- **Development tools**: Neovim, tmux, mise, and others
- **Encrypted secrets**: SSH keys, API tokens, and credentials protected with Age encryption
- **Automated security scanning**: GitHub Actions workflow with Gitleaks and TruffleHog
- **Pre-commit hooks**: Local validation before commits

## Quick Start

### Prerequisites

Install the required tools:

```bash
# Chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"
```

```bash
# Age (for encryption)
# Fedora
sudo dnf install age
```

### Installation

Initialize the dotfiles (read-only without decryption key):

```bash
chezmoi init https://github.com/AgustinH09/dotfiles-public.git
```

To preview what would be applied:

```bash
chezmoi diff
```

Note: Without the Age decryption key, encrypted files will not be applied. This is intentional for security.

## Security

All sensitive files are encrypted using Age encryption. The repository includes:

- Automated security scanning on every push
- Pre-commit hooks for local validation

For security details, see:

- [.github/SECURITY_QUICK_REFERENCE.md](.github/SECURITY_QUICK_REFERENCE.md) - Quick reference guide

## Usage Notes

These dotfiles are tailored for my specific setup:

- Fedora Linux with Hyprland
- NVIDIA GPU configuration
- Japanese input (fcitx5)
- Specific development workflows

Feel free to browse and use as inspiration

## Contributing

This is a personal dotfiles repository. While pull requests are welcome for bug fixes or improvements, please note that configurations reflect my personal preferences and workflow.

## Acknowledgments

This configuration builds upon and is inspired by several excellent open-source projects:

- **Hyprland configuration** based on [JaKooLit/Hyprland-Dots](https://github.com/JaKooLit/Hyprland-Dots)
- **Chezmoi** for dotfiles management
- **Age** for encryption
- Various other tools and configurations from the dotfiles community

Special thanks to JaKooLit for the comprehensive Hyprland setup and to all maintainers of the tools used here.
