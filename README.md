# Agents macOS Setup (Sandbox V2)

A secure architecture for running AI agents (Gemini, OpenCode) on macOS with strict macOS sandbox enforcement. Uses the native `sandbox-exec` kernel extension to deny home directory access by default.

## Architecture

- **Admin User (`cyrils`)**: Your primary macOS user with full system access.
- **Agent User (`agents`)**: Restricted non-admin user for AI tools.
- **Sandbox**: Enforces `(deny default)` + allowlist model - blocks ALL home directory access by default.
- **Workspace**: Only `/Users/cyrils/Developer/` is allowed (read/write).
- **Toolchain**: Read-only access to `/opt/homebrew`.

## Key Changes (V2)

1. **Default-Deny Home Directory**: Blocks all of `/Users/cyrils/*` access by default, allows only `Developer/`
2. **Default-Deny Process Exec**: Blocks all process execution by default, allows only system bins + homebrew
3. **Wrapper Scripts**: `opencode-sandbox` and `gemini-sandbox` handle env clearing + sandbox execution
4. **Clean Environment**: Uses `env -i` to clear environment variables, reducing attack surface

## 1. Setup

### Create the Agent User:
```bash
sudo sysadminctl -addUser agents -password "SET_AGENT_PASSWORD" -fullName "AI Agent"
```

### Configure ACLs:
```bash
# 1. Allow traversal to admin home
chmod +a "user:agents allow search" /Users/cyrils

# 2. Grant access to work directory
sudo chmod -R +a "user:agents allow read,write,delete,add_file,add_subdirectory,file_inherit,directory_inherit" /Users/cyrils/Developer

# 3. Setup Agent Home
sudo chown -R agents:staff /Users/agents
sudo chmod 770 /Users/agents

# 4. Allow admin to access agents folder
sudo chmod +a "user:cyrils allow read,write,delete,add_file,add_subdirectory,file_inherit,directory_inherit" /Users/agents
```

### Run Setup Script:
```bash
cd ~/Developer/GitHub/Agents-MacOS-Setup
./setup.sh
```

### Add to Host .zshrc:
```bash
source ~/Developer/GitHub/Agents-MacOS-Setup/host_zshrc_snippet.zsh
```

## 2. Sandbox Profile (`agent-profile.sb`)

The sandbox enforces:

- **Deny Home Directory**: `(deny file-read* (subpath "/Users/cyrils"))` - blocks ALL of cyrils home
- **Deny Process Exec**: `(deny process-exec)` - blocks all execution
- **Allow Workspace**: Only `/Users/cyrils/Developer/` has read/write
- **Allow Toolchain**: System bins + homebrew only
- **Allow Agent Home**: Full access to `/Users/agents`
- **Network**: Outbound allowed for LLM APIs

## 3. Wrapper Scripts

Two wrapper scripts handle the sandbox execution:

### `opencode-sandbox`
```bash
#!/usr/bin/env bash
exec /usr/bin/env -i \
  HOME="$HOME" PATH="$PATH" ... \
  /usr/bin/sandbox-exec -f agent-profile.sb opencode "$@"
```

Key flags:
- Uses `env -i` to clear environment
- Sets `OPENCODE_DISABLE_*` flags to disable unnecessary features
- Runs under `agent-profile.sb` sandbox

### `gemini-sandbox`
Similar wrapper for Google Gemini CLI.

## 4. Security Rules (AGENTS.md.template)

All agents operating in this environment are bound by:
- **Deny Home by Default**: No access to `/Users/cyrils/*` except `/Developer/`
- **Read-Only Toolchain**: Never modify Homebrew packages
- **No Escalation**: Never use `sudo` or attempt privilege escalation
- **Explicit Allow**: Only access project directories and temp files

## Usage

After setup:
```bash
opencode "fix this bug"
gemini "explain this code"

# Or use ai() bridge
ai opencode "fix this bug"
ai gemini "explain this code"
```

## Verification

```bash
# This should be blocked:
$ opencode ls /Users/cyrils/Documents
ls: /Users/cyrils/Documents: Operation not permitted

# This should work:
$ opencode ls /Users/cyrils/Developer
# (shows files)
```

## Files

| File | Purpose |
|------|---------|
| `agent-profile.sb` | Main sandbox profile |
| `opencode-sandbox` | OpenCode wrapper script |
| `gemini-sandbox` | Gemini CLI wrapper script |
| `host_zshrc_snippet.zsh` | Host bridge functions |
| `agent_zshrc.zsh` | Agent user environment |
| `AGENTS.md.template` | Agent instructions |
| `opencode-config.json` | OpenCode configuration |
| `setup.sh` | Automated setup script |