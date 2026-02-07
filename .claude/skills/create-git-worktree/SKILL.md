---
name: create-git-worktree
description:
  Use when starting feature work that needs isolation from current workspace or
  before executing implementation plans - creates an isolated git worktree with
  smart directory selection and safety verification
disable-model-invocation: true
allowed-tools:
  - Read
  - Bash(python *)
  - Bash(ls *)
---

# Create Git Worktree

## Overview

Git worktrees create isolated workspaces sharing the same repository, allowing
work on multiple branches simultaneously without switching.

**Announce at start:** "I'm using the create-git-worktree skill to set up an
isolated workspace."

## Script Reference

This skill has access to the following scripts to facilitate worktree creation
and configuration:

| Script                       | Description                                                      | Reference                       |
| ---------------------------- | ---------------------------------------------------------------- | ------------------------------- |
| `scripts/setup_worktree.py`  | Creates worktree with branch verification and freshness checks   | `references/setup-worktree.md`  |
| `scripts/sync_worktreerc.py` | Copies gitignored config files (`.env`, etc.) from main worktree | `references/sync-worktreerc.md` |

Read the reference file when you need specifics about a script's arguments,
output format, or error handling.

## Prerequisites

This skill accepts a **branch name** as its argument.

All prerequisite checks (default branch detection, branch verification, and
freshness against origin) are handled by the `setup_worktree.py` script. The
script detects the default branch via
`git symbolic-ref refs/remotes/origin/HEAD` with an automatic fallback to
`git remote show origin` for repos where the symbolic ref isn't set.

The `setup_worktree.py` must be run as the first step in the process of creating
a worktree.

## Directory Selection Process

### 1. Worktree Directories Location

Worktree directories should be created in the parent directory of the primary
git repository, not inside it. This prevents pollution of the main workspace.

For example, if the current repository is at
`/Users/jesse/Code/myproject/myproject`, the new worktree directory should be
created in `/Users/jesse/Code/myproject/<worktree-dir-name>`.

### 2. Ask User If New Directory Doesn't Follow Conventions

If following the convention outlined above will result in a new worktree
directory that is outside of the project, ask the user where they would like to
create worktree directory.

For example:

```text
Creating a worktree diretory at <path> does not confirm to worktree dirctory conventions because <reason>.

Where should I create worktrees?
```

## Creation Steps

**Important:** Do not run any git commands directly (e.g., `git rev-parse`,
`git branch`). The setup script handles all git operations internally and its
JSON output provides everything needed (worktree path, branch, base SHA, etc.).

### 1. Setup & Create Worktree

```bash
python scripts/setup_worktree.py <BRANCH_NAME>
```

The script outputs JSON to stdout. Parse the result and handle accordingly:

| `status`        | Meaning                         | Action                                                      |
| --------------- | ------------------------------- | ----------------------------------------------------------- |
| `success`       | Worktree created                | Continue to step 2. Use `worktree_path` from the output.    |
| `wrong_branch`  | Not on the default branch       | Ask user to switch to `default_branch`, then re-run step 1. |
| `behind_origin` | Default branch is behind origin | Ask user to pull latest changes, then re-run step 1.        |
| `error`         | Something else went wrong       | Show `message` to the user and stop.                        |

### 2. Sync Worktree Config

```bash
python scripts/sync_worktreerc.py <worktree_path>
```

Where `<worktree_path>` is the `worktree_path` value from step 1's JSON output.

If the main worktree has a `.worktreerc` file, this copies matching config files
(e.g., `.env`, IDE settings) that are gitignored but needed for the project.
Safe to skip if there is no `.worktreerc` — the script handles that gracefully.

### 3. Report Location

```text
Worktree ready at <full-path>
Branch: <branch> (based on <default_branch> at <base_sha>)
```

## Quick Reference

| Situation                    | Action                                             |
| ---------------------------- | -------------------------------------------------- |
| Not on default branch        | Script returns `wrong_branch` — ask user to switch |
| Default branch behind origin | Script returns `behind_origin` — ask user to pull  |
| Branch name has slashes      | Script sanitizes: replaces `/` with `-` in path    |
| `.worktreerc` exists         | Sync matching files to new worktree                |
| `.worktreerc` not found      | Skip sync (script exits gracefully)                |

## Common Mistakes

### Creating worktree from non-default branch

- **Problem:** Worktree diverges from a stale base, not the latest mainline
- **Fix:** The setup script enforces this — handle `wrong_branch` status

### Not pulling latest changes

- **Problem:** Worktree starts from outdated code, leading to merge conflicts
- **Fix:** The setup script enforces this — handle `behind_origin` status

## Red Flags

**Never:**

- Ignore `wrong_branch` or `behind_origin` status from the setup script
- Run git commands directly — the setup script handles all git operations

**Always:**

- Use `scripts/setup_worktree.py` for creation (handles branch verification +
  freshness)
- Sync `.worktreerc` files after creating the worktree with the
  `scripts/sync_worktreerc.py` script
