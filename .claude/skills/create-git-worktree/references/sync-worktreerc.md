# sync_worktreerc.py Reference

## Usage

```bash
python ~/.claude/skills/create-git-worktree/scripts/sync_worktreerc.py <worktree-path>
```

`<worktree-path>` is the target worktree directory. If omitted, defaults to
the current working directory.

## What It Does

Copies gitignored config files from the main worktree into the current worktree
based on glob patterns defined in `.worktreerc`.

## How It Works

1. Finds the main worktree via `git worktree list --porcelain` (first entry)
2. Reads `.worktreerc` from the main worktree root
3. Globs each pattern against the main worktree
4. Copies matching files and directories into the current worktree, with two
   exceptions:
   - Skips `.worktreerc` itself
   - Skips files that already exist in the target

Parent directories are created as needed. Directories are copied recursively
(`shutil.copytree`); files are copied preserving metadata (`shutil.copy2`).

## `.worktreerc` Format

Plain text, one glob pattern per line. `#` comments and blank lines are ignored.

```text
# Environment files
.env
.env.*

# IDE settings
.vscode/settings.json
```

## Output

Prints each copied file to stdout:

```text
Syncing from /Users/jesse/Code/myproject/myproject into /Users/jesse/Code/myproject/feature-auth:
  copied .env
  copied .env.local
Done.
```

When there is nothing to do:

- **No `.worktreerc` or empty patterns:** `No .worktreerc found or no patterns defined.`
- **Already in main worktree:** `Already in main worktree, nothing to sync.`
- **Not a git repo:** `Error: Could not determine main worktree. Are you in a git repository?`

## Exit Codes

| Code | Meaning                                                    |
| ---- | ---------------------------------------------------------- |
| `0`  | Success, or graceful no-op (no `.worktreerc`, main worktree) |
| `1`  | Not inside a git repository                                |
