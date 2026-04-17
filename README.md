# Agents macOS Setup (M4 Pro Isolation)

A secure architecture for running AI agents (Gemini, OpenCode, OpenClaw) on macOS with strict user isolation and sandbox enforcement. Optimized for Apple Silicon.

## Architecture

- **Master User (`cyrils`)**: Admin user with full system access.
- **Agent User (`agents`)**: Restricted non-admin user dedicated to AI tools.
- **Isolation Tunnel**: Precise ACLs allow the `agents` user to traverse into `~/Developer` while blocking all other private folders (`Documents`, `Desktop`, `.ssh`).
- **Sandbox enforcement**: `sandbox-exec` profile at `~/.config/sandboxes/agent-profile.sb` locks the agent into a read-only system toolchain and its own home directory.

## 1. Setup

### Create the Agent User:
```bash
sudo sysadminctl -addUser agents -password "SET_AGENT_PASSWORD" -fullName "AI Agent"
```

### Configure Isolation Tunnel:
```bash
# 1. Allow agent to reach subfolders (traversal)
chmod +a "user:agents allow search" /Users/cyrils

# 2. Grant access to work directory
sudo chmod -R +a "user:agents allow read,write,delete,add_file,add_subdirectory,file_inherit,directory_inherit" /Users/cyrils/Developer

# 3. Setup Agent Home and cross-access for master
sudo chown -R agents:staff /Users/agents
sudo chmod 770 /Users/agents
sudo dseditgroup -o edit -a cyrils -t user staff

# 4. Finalize ACL for cyrils
sudo chmod +a "user:cyrils allow read,write,delete,add_file,add_subdirectory,file_inherit,directory_inherit" /Users/agents
```

### Install the `ai` bridge function:
Add this to your `~/.zshrc`:
```bash
ai() {
    if [ $# -eq 0 ]; then
        echo "Usage: ai <command> [args]"
        return 1
    fi

    local profile="$HOME/.config/sandboxes/agent-profile.sb"
    local project_dir=$(pwd)

    # -u agents: Switch to isolated user
    # -H: Force sudo to set HOME=/Users/agents correctly
    sudo -u agents -H \
        /usr/bin/sandbox-exec -f "$profile" \
        -D PROJECT_DIR="$project_dir" \
        /usr/bin/env HOME=/Users/agents PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" "$@"
}
```

## 2. Sandbox Profile (`agent-profile.sb`)

The sandbox at `~/.config/sandboxes/agent-profile.sb` enforces the following:
- **Stability**: Uses `(allow default)` + `(deny /Users/cyrils)` for M4 Silicon stability.
- **The Wall**: Absolute block on master user files (`Documents`, `Desktop`, `.ssh`).
- **The Bridge**: The ONLY allowed bridge to work folders (`Developer`).
- **Network**: Cloud connectivity for LLM APIs.
- **Docker**: Bridged access to Colima socket at `~/.colima/default/docker.sock`.
- **Homebrew**: Read-only toolchain access (prevents unauthorized package installs).

## 3. Security Rules (AGENTS.md)

All agents operating in this environment are bound by these rules:
- **Isolation**: ALWAYS operate within `/Users/agents` or the provided `PROJECT_DIR`.
- **No Escalation**: NEVER attempt to use `sudo` or `chmod` on system files.
- **Read-Only Tools**: NEVER attempt to `brew install` or modify the Homebrew toolchain.
- **Privacy**: No access to the master user's private data is permitted or possible.
