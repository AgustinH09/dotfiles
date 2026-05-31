# Zero-Trust npm Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Secure the local Fedora environment against supply-chain worms by enforcing `ignore-scripts=true` globally and routing all global `npm` and `node` execution through ephemeral, rootless Podman containers.

**Architecture:** Use `chezmoi` to manage a new `.npmrc` file, and inject shell aliases into `dot_bashrc.tmpl` and `dot_zshrc.tmpl` to seamlessly proxy `npm`, `npx`, and `node` traffic to Podman containers while mapping local network ports and permissions.

**Tech Stack:** `chezmoi`, `podman`, `bash`, `zsh`

---

### Task 1: Reconcile Chezmoi Templates

Before editing template files, we must ensure the `dotfiles` repository is in sync with the actual local configuration. If local scripts have modified `~/.bashrc` directly, `chezmoi apply` will overwrite them.

**Files:**
- None created, resolving state.

- [ ] **Step 1: Check for chezmoi diffs on bashrc**

Run: `chezmoi diff ~/.bashrc`
Expected: If there is a diff, we must copy the local additions back into `dot_bashrc.tmpl` first. If no diff, proceed.

- [ ] **Step 2: Check for chezmoi diffs on zshrc**

Run: `chezmoi diff ~/.zshrc`
Expected: If there is a diff, we must copy the local additions back into `dot_zshrc.tmpl` first. If no diff, proceed.

### Task 2: Enforce Global npm Configuration

**Files:**
- Create: `dot_npmrc`

- [ ] **Step 1: Create the dot_npmrc file**

```ini
ignore-scripts=true
```

- [ ] **Step 2: Apply the chezmoi configuration**

Run: `chezmoi apply ~/.npmrc`
Expected: File applied successfully.

- [ ] **Step 3: Verify the configuration**

Run: `cat ~/.npmrc`
Expected: Output shows `ignore-scripts=true`.

### Task 3: Inject Podman Aliases for Bash

**Files:**
- Modify: `dot_bashrc.tmpl`

- [ ] **Step 1: Append Podman aliases to dot_bashrc.tmpl**

Modify the file by adding this block at the bottom:

```bash
# --- Zero-Trust Containerized npm/Node ---
if [[ "$AGENT_MODE" != "true" ]]; then
  alias npm="podman run --rm -it --userns=keep-id -v \$(pwd):/workspace -w /workspace -p 3000:3000 -p 5173:5173 -p 8080:8080 docker.io/library/node:lts-alpine npm"
  alias npx="podman run --rm -it --userns=keep-id -v \$(pwd):/workspace -w /workspace -p 3000:3000 -p 5173:5173 -p 8080:8080 docker.io/library/node:lts-alpine npx"
  alias safe-node="node --permission --allow-fs-read=\$(pwd) --allow-net"
fi
```

- [ ] **Step 2: Apply the changes via chezmoi**

Run: `chezmoi apply ~/.bashrc`
Expected: Applied successfully without errors.

### Task 4: Inject Podman Aliases for Zsh

**Files:**
- Modify: `dot_zshrc.tmpl`

- [ ] **Step 1: Append Podman aliases to dot_zshrc.tmpl**

Modify the file by adding this block right before the `# --- Profiling ---` section:

```zsh
# --- Zero-Trust Containerized npm/Node ---
if [[ "$AGENT_MODE" != "true" ]]; then
  alias npm="podman run --rm -it --userns=keep-id -v \$(pwd):/workspace -w /workspace -p 3000:3000 -p 5173:5173 -p 8080:8080 docker.io/library/node:lts-alpine npm"
  alias npx="podman run --rm -it --userns=keep-id -v \$(pwd):/workspace -w /workspace -p 3000:3000 -p 5173:5173 -p 8080:8080 docker.io/library/node:lts-alpine npx"
  alias safe-node="node --permission --allow-fs-read=\$(pwd) --allow-net"
fi
```

- [ ] **Step 2: Apply the changes via chezmoi**

Run: `chezmoi apply ~/.zshrc`
Expected: Applied successfully without errors.

### Task 5: Commit Implementation

- [ ] **Step 1: Commit the changes to the dotfiles repository**

Run:
```bash
git add dot_npmrc dot_bashrc.tmpl dot_zshrc.tmpl
git commit -m "feat(security): enforce zero-trust npm containerization via podman"
```
Expected: Commit succeeds cleanly.
