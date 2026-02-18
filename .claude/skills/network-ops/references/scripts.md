# Scripts Reference

## check-hosts.sh

**Path:** `scripts/check-hosts.sh`

Check connectivity to all hosts in the network inventory via SSH.

### Usage

```bash
bash scripts/check-hosts.sh
```

### Output Format

```
beelink    192.168.1.137    LOCAL
m2pro      192.168.1.140    OK
nucbox     192.168.1.31     OK
```

Each line shows: hostname, IP address, and status.

### Status Values

| Status        | Meaning                                               |
|---------------|-------------------------------------------------------|
| `LOCAL`       | This is the machine the script is running on          |
| `OK`          | SSH connection succeeded (key auth, 3-second timeout) |
| `UNREACHABLE` | SSH connection failed — host may be down or SSH not running |

### How It Works

1. Compares each host against `$(hostname)` to identify the local machine
2. For remote hosts, runs `ssh -o ConnectTimeout=3 -o BatchMode=yes` to test connectivity
3. `BatchMode=yes` ensures no password prompts — fails immediately if key auth isn't set up

### Maintenance

To add or remove hosts, update the `HOSTS` associative array at the top of the script. Keep it in sync with the host inventory in SKILL.md.
