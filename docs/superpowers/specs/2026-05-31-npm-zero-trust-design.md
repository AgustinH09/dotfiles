# Zero-Trust npm Workflow: The Fedora Native Sandbox

## Goal
To completely secure the developer's local Fedora machine from supply-chain worms and malicious post/pre-install scripts originating from npm dependencies, without fundamentally changing the primary package manager. 

The approach must allow the user to clone untrusted repositories and run `npm install` without fear of the code accessing local `.ssh` keys, `API` keys, or executing background ransomware/worms.

## Architecture & Components

We will implement the "Fedora Native Sandbox" approach, utilizing the native rootless capabilities of Podman, combined with strict global configuration hardening.

### 1. Global npm Configuration (Host & Container)
- **Component:** `.npmrc` file managed by chezmoi (`dot_npmrc`).
- **Function:** Enforce `ignore-scripts=true` globally. Even if a containerized install is bypassed or a non-containerized install is accidentally run, lifecycle scripts (where 99% of malware detonates) will be blocked.

### 2. The Podman Sandbox Aliases
- **Component:** Bash/Zsh aliases in `dot_bashrc.tmpl` and `dot_zshrc.tmpl`.
- **Function:** Transparently replace `npm`, `npx`, and `node` commands with ephemeral Podman containers.
- **Data Flow:**
  - When the user types `npm install`, the alias intercepts it.
  - It spins up a temporary `node:lts-alpine` container.
  - The current working directory `$(pwd)` is mounted into the container at `/workspace`.
  - The user's UID and GID are passed to the container (e.g., `--userns=keep-id` in Podman or `--user $(id -u):$(id -g)`) to ensure all generated files in `node_modules` are owned by the local user, not root.
  - Network ports (e.g., `-p 3000:3000 -p 5173:5173`) are explicitly exposed to allow dev servers (Next.js, Vite) to work seamlessly.

### 3. Safe Node Execution Environment
- **Component:** `safe-node` alias.
- **Function:** When executing individual node scripts, this alias will wrap the command with the Node.js 23+ Permission Model (`--permission --allow-fs-read=$(pwd) --allow-net`).

## Security Trade-offs & Error Handling

- **Friction - Native Modules:** Legitimate packages requiring `node-gyp` (C++ compilation) will fail because `ignore-scripts=true`. 
  - *Handling:* The user will be trained to selectively run `npm rebuild` for specific, trusted packages inside the container.
- **Friction - Dev Servers:** By default, containers isolate the network.
  - *Handling:* The `npm` alias will include common port mappings (`-p 3000:3000 -p 5173:5173 -p 8080:8080`) to reduce friction.
- **Global CLIs:** Installing global packages (`npm install -g typescript`) will not persist.
  - *Handling:* The user will rely on `npx <tool>` which fetches and runs the tool ephemerally and safely inside the container.

## Testing & Verification
1. **Permission Test:** Run `npm install lodash` via the alias. Verify that the `node_modules` folder on the host is owned by the user, not root.
2. **Execution Test:** Attempt to run a script containing malicious file access (`fs.readFileSync('~/.ssh/id_rsa')`) using the `safe-node` alias and confirm it throws an `ERR_ACCESS_DENIED` exception.
3. **Environment Test:** Verify that `ignore-scripts=true` is correctly applied when running `npm config get ignore-scripts` inside the container alias.
