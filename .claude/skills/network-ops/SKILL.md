---
name: Network Operations
description: >-
  This skill should be used when the user asks to "SSH into a host",
  "copy files between machines", "transfer files to/from a host",
  "connect to a remote machine", "sync files", "check if hosts are up",
  "run a command on a remote host", or references any host by name
  (beelink, m2pro, nucbox). Covers all SSH, SCP, rsync, and network
  connectivity operations across the user's local network.
---

## Network Operations Skill

Provides host inventory and operational patterns for SSH-based operations
across the user's local network.

### Host Inventory

| Host     | IP              | OS            | Notes                   |
|----------|-----------------|---------------|-------------------------|
| beelink  | 192.168.1.137   | Ubuntu Server | Main dev machine        |
| m2pro    | 192.168.1.140   | Ubuntu Server |                         |
| nucbox   | 192.168.1.31    | Ubuntu Server |                         |

- **SSH username on all hosts:** `salim`
- **Authentication:** SSH key-based (no passwords)

### Determining the Local Host

Before performing any operation, determine which host Claude is currently
running on:

```bash
hostname
```

Compare the result against the host inventory. The local host does not need
SSH for local file operations — only use SSH/SCP/rsync for remote hosts.

---

### SSH Connection

To connect to a remote host:

```bash
ssh salim@<ip>
```

To run a single command on a remote host without an interactive session:

```bash
ssh salim@<ip> '<command>'
```

To run multiple commands:

```bash
ssh salim@<ip> 'command1 && command2'
```

---

### File Transfer Operations

#### Copy files to a remote host (SCP)

```bash
scp /local/path salim@<ip>:/remote/path
```

#### Copy files from a remote host (SCP)

```bash
scp salim@<ip>:/remote/path /local/path
```

#### Copy directories recursively (SCP)

```bash
scp -r /local/dir salim@<ip>:/remote/dir
```

#### Sync files with rsync (preferred for large or repeated transfers)

Push local to remote:

```bash
rsync -avz /local/path/ salim@<ip>:/remote/path/
```

Pull remote to local:

```bash
rsync -avz salim@<ip>:/remote/path/ /local/path/
```

Key rsync flags:
- `-a` — archive mode (preserves permissions, timestamps, symlinks)
- `-v` — verbose
- `-z` — compress during transfer
- `--progress` — show transfer progress
- `--delete` — delete files on destination not present on source (use with caution)
- `--dry-run` — preview what would be transferred without executing

---

### Connectivity Checks

To check if a host is reachable:

```bash
ping -c 1 -W 2 <ip>
```

To check if SSH is available on a host:

```bash
ssh -o ConnectTimeout=3 -o BatchMode=yes salim@<ip> echo ok
```

Use `scripts/check-hosts.sh` to check all hosts at once.

---

### Common Workflows

#### Transfer a file between two remote hosts (via local)

When the current host is neither the source nor the destination, pull then
push:

```bash
scp salim@<source_ip>:/path/to/file /tmp/file
scp /tmp/file salim@<dest_ip>:/path/to/file
rm /tmp/file
```

#### Transfer directly between two remote hosts

Use SSH proxying to avoid storing files locally:

```bash
ssh salim@<source_ip> "cat /path/to/file" | ssh salim@<dest_ip> "cat > /path/to/file"
```

#### Sync a directory between two remote hosts

```bash
rsync -avz -e ssh salim@<source_ip>:/path/to/dir/ salim@<dest_ip>:/path/to/dir/
```

Note: This requires the local machine to have SSH access to both hosts.

---

### Port Forwarding

Forward a remote port to local:

```bash
ssh -L <local_port>:localhost:<remote_port> salim@<ip>
```

Forward a local port to remote:

```bash
ssh -R <remote_port>:localhost:<local_port> salim@<ip>
```

---

### Safety Considerations

- Always confirm the target host and path before destructive operations
  (e.g., `rsync --delete`, `rm` on remote)
- Use `--dry-run` with rsync before actual transfers
- When transferring between hosts, verify available disk space on the
  destination with `ssh salim@<ip> 'df -h /path'`

### Utility Scripts

- **`scripts/check-hosts.sh`** — Check connectivity to all hosts in the inventory

### Reference Files

- **`references/scripts.md`** — Detailed documentation for all scripts (usage, output format, maintenance)
