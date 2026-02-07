# setup_worktree.py Reference

## Usage

```bash
python scripts/setup_worktree.py <branch-name> [--parent-dir <path>]
```

| Argument        | Required | Description                                                  |
| --------------- | -------- | ------------------------------------------------------------ |
| `<branch-name>` | Yes      | Name for the new worktree branch                             |
| `--parent-dir`  | No       | Directory in which to create the worktree (default: parent of repo root) |

## What It Does

Creates an isolated git worktree for the given branch after verifying the repo
is on a fresh default branch.

## Checks Performed

1. **Git repo detection** — confirms `cwd` is inside a git repository
2. **Default branch detection** — tries `git symbolic-ref refs/remotes/origin/HEAD`;
   falls back to `git remote show origin` if the symbolic ref isn't set
3. **Branch verification** — ensures the current branch is the default branch
4. **Fetch + freshness check** — fetches `origin/<default>` and compares local
   vs remote SHA; rejects if local is behind
5. **Path computation** — places the worktree in the parent of the repo root
   (or the directory given by `--parent-dir`), sanitizing `/` to `-` in the
   branch name (e.g. `feature/auth` becomes `feature-auth`)
6. **Collision check** — errors if the computed path already exists
7. **`git worktree add`** — creates the worktree with a new branch (`-b`)

## Output Format

JSON object printed to **stdout**. The `status` field determines which
additional fields are present.

### `success`

Worktree created successfully.

```json
{
  "status": "success",
  "worktree_path": "/Users/jesse/Code/myproject/feature-auth",
  "branch": "feature/auth",
  "default_branch": "main",
  "base_sha": "abc1234..."
}
```

| Field            | Description                                   |
| ---------------- | --------------------------------------------- |
| `worktree_path`  | Absolute path to the new worktree directory   |
| `branch`         | Branch name as provided                       |
| `default_branch` | Detected default branch (e.g. `main`)         |
| `base_sha`       | Commit SHA the worktree was created from      |

### `wrong_branch`

Current branch is not the default branch.

```json
{
  "status": "wrong_branch",
  "current_branch": "feature/old",
  "default_branch": "main"
}
```

| Field            | Description                          |
| ---------------- | ------------------------------------ |
| `current_branch` | The branch currently checked out     |
| `default_branch` | The branch the user should switch to |

### `behind_origin`

Local default branch is behind `origin/<default>`.

```json
{
  "status": "behind_origin",
  "default_branch": "main"
}
```

| Field            | Description                                |
| ---------------- | ------------------------------------------ |
| `default_branch` | The branch that needs to be pulled/updated |

### `error`

A catch-all for other failures.

```json
{
  "status": "error",
  "message": "Path already exists: /Users/jesse/Code/myproject/feature-auth"
}
```

| Field     | Description                   |
| --------- | ----------------------------- |
| `message` | Human-readable error message  |

## Exit Codes

| Code | Meaning                                               |
| ---- | ----------------------------------------------------- |
| `0`  | `success` — worktree created                          |
| `1`  | Any other status (`wrong_branch`, `behind_origin`, `error`) |
