---
name: create-git-worktree
description:
  Use when starting feature work that needs isolation from current workspace or
  before executing implementation plans - creates an isolated git worktree with
  smart directory selection and safety verification
disable-model-invocation: true
allowed-tools:
  - Bash(python *)
---

# Create Git Worktree

## Overview

Git worktrees create isolated workspaces sharing the same repository, allowing
work on multiple branches simultaneously without switching.

**Announce at start:** "I'm using the create-git-worktree skill to set up an
isolated workspace."

## Prerequisites

This skill accepts a **branch name** as its argument.

All prerequisite checks (default branch detection, branch verification, and
freshness against origin) are handled by the `setup_worktree.py` script. The
script detects the default branch via `git symbolic-ref refs/remotes/origin/HEAD`
with an automatic fallback to `git remote show origin` for repos where the
symbolic ref isn't set.

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

### 1. Setup & Create Worktree

```bash
python ~/.claude/skills/create-git-worktree/scripts/setup_worktree.py <BRANCH_NAME>
```

The script outputs JSON to stdout. Parse the result and handle accordingly:

| `status`       | Meaning                                  | Action                                                        |
| -------------- | ---------------------------------------- | ------------------------------------------------------------- |
| `success`      | Worktree created                         | Continue to step 2. Use `worktree_path` from the output.      |
| `wrong_branch` | Not on the default branch                | Ask user to switch to `default_branch`, then re-run step 1.   |
| `behind_origin`| Default branch is behind origin          | Ask user to pull latest changes, then re-run step 1.          |
| `error`        | Something else went wrong                | Show `message` to the user and stop.                          |

### 2. Sync Worktree Config

Run from inside the new worktree directory:

```bash
python ~/.claude/skills/create-git-worktree/scripts/sync_worktreerc.py
```

If the main worktree has a `.worktreerc` file, this copies matching config files
(e.g., `.env`, IDE settings) that are gitignored but needed for the project.
Safe to skip if there is no `.worktreerc` — the script handles that gracefully.

### 3. Run Project Setup

Auto-detect and run appropriate setup:

```bash
# Node.js
if [ -f package.json ]; then npm install; fi

# Rust
if [ -f Cargo.toml ]; then cargo build; fi

# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi

# Go
if [ -f go.mod ]; then go mod download; fi
```

### 4. Verify Clean Baseline

Run tests to ensure worktree starts clean:

```bash
# Examples - use project-appropriate command
npm test
cargo test
pytest
go test ./...
```

**If tests fail:** Report failures, ask whether to proceed or investigate.

**If tests pass:** Report ready.

### 5. Report Location

```
Worktree ready at <full-path>
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```

## Quick Reference

| Situation                    | Action                                            |
| ---------------------------- | ------------------------------------------------- |
| Not on default branch        | Script returns `wrong_branch` — ask user to switch|
| Default branch behind origin | Script returns `behind_origin` — ask user to pull |
| Branch name has slashes      | Script sanitizes: replaces `/` with `-` in path   |
| Tests fail during baseline   | Report failures + ask                             |
| No package.json/Cargo.toml   | Skip dependency install                           |
| `.worktreerc` exists         | Sync matching files before project setup          |
| `.worktreerc` not found      | Skip sync (script exits gracefully)               |

## Common Mistakes

### Creating worktree from non-default branch

- **Problem:** Worktree diverges from a stale base, not the latest mainline
- **Fix:** The setup script enforces this — handle `wrong_branch` status

### Not pulling latest changes

- **Problem:** Worktree starts from outdated code, leading to merge conflicts
- **Fix:** The setup script enforces this — handle `behind_origin` status

### Proceeding with failing tests

- **Problem:** Can't distinguish new bugs from pre-existing issues
- **Fix:** Report failures, get explicit permission to proceed

### Running project setup before syncing worktreerc

- **Problem:** Setup commands fail because config files (`.env`, etc.) are
  missing
- **Fix:** Always run the worktreerc sync step before project setup

### Hardcoding setup commands

- **Problem:** Breaks on projects using different tools
- **Fix:** Auto-detect from project files (package.json, etc.)

## Example Workflow

```
You: I'm using the create-git-worktree skill to set up an isolated workspace.

[Run setup_worktree.py feature/auth → success, path: /Users/jesse/Code/myproject/feature-auth]
[Sync worktreerc: copied .env, copied .env.local]
[Run npm install]
[Run npm test - 47 passing]

Worktree ready at /Users/jesse/Code/myproject/feature-auth
Tests passing (47 tests, 0 failures)
Ready to implement auth feature
```

## Red Flags

**Never:**

- Ignore `wrong_branch` or `behind_origin` status from the setup script
- Run project setup before syncing `.worktreerc` files
- Skip baseline test verification
- Proceed with failing tests without asking

**Always:**

- Use `setup_worktree.py` for creation (handles branch verification + freshness)
- Sync `.worktreerc` files before running project setup
- Auto-detect and run project setup
- Verify clean test baseline

## Integration

**Called by:**

- **brainstorming** (Phase 4) - REQUIRED when design is approved and
  implementation follows
- **subagent-driven-development** - REQUIRED before executing any tasks
- **executing-plans** - REQUIRED before executing any tasks
- Any skill needing isolated workspace

**Pairs with:**

- **finishing-a-development-branch** - REQUIRED for cleanup after work complete
