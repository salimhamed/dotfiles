---
name: create-git-worktree
description:
  Use when starting feature work that needs isolation from current workspace or
  before executing implementation plans - creates an isolated git worktree with
  smart directory selection and safety verification
disable-model-invocation: true
allowed-tools:
  - Bash(git *)
  - Bash(python *)
---

# Create Git Worktree

## Overview

Git worktrees create isolated workspaces sharing the same repository, allowing
work on multiple branches simultaneously without switching.

**Core principle:** Systematic directory selection + safety verification =
reliable isolation.

**Announce at start:** "I'm using the create-git-worktree skill to set up an
isolated workspace."

## Prerequisites

This skill accepts a **branch name** as its argument.

### 1. Verify Default Branch

The worktree must be created from the default branch. Detect and verify:

```bash
default_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's|refs/remotes/origin/||')
current_branch=$(git branch --show-current)

if [ "$current_branch" != "$default_branch" ]; then
  echo "Current branch is '$current_branch', not '$default_branch'."
  echo "Switch to '$default_branch' before creating a worktree, or abort."
fi
```

### 2. Check Freshness

Compare the local default branch with origin. If behind, prompt the user to pull
before proceeding:

```bash
git fetch origin "$default_branch" --quiet
local_sha=$(git rev-parse "$default_branch")
remote_sha=$(git rev-parse "origin/$default_branch")

if [ "$local_sha" != "$remote_sha" ]; then
  echo "'$default_branch' is behind origin. Pull latest changes before creating worktree?"
fi
```

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

### 1. Detect Project Name

```bash
project=$(basename "$(git rev-parse --show-toplevel)")
```

### 2. Create Worktree

```bash
repo_root=$(git rev-parse --show-toplevel)
parent_dir=$(dirname "$repo_root")

# Sanitize branch name: replace / with -
sanitized=$(echo "$BRANCH_NAME" | tr '/' '-')

path="$parent_dir/$sanitized"

git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

### 3. Sync Worktree Config

If the main worktree has a `.worktreerc` file, sync matching files into the new
worktree. This copies config files (e.g., `.env`, IDE settings) that are
gitignored but needed for the project to function.

```bash
python ~/.claude/skills/create-git-worktree/scripts/sync_worktreerc.py
```

This step is safe to skip if there is no `.worktreerc` — the script handles
that gracefully.

### 4. Run Project Setup

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

### 5. Verify Clean Baseline

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

### 6. Report Location

```
Worktree ready at <full-path>
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```

## Quick Reference

| Situation                    | Action                             |
| ---------------------------- | ---------------------------------- |
| Not on default branch        | Switch to default branch or abort  |
| Default branch behind origin | Prompt user to pull latest changes |
| Branch name has slashes      | Sanitize: replace `/` with `-`     |
| Tests fail during baseline   | Report failures + ask              |
| No package.json/Cargo.toml   | Skip dependency install            |
| `.worktreerc` exists         | Sync matching files before project setup |
| `.worktreerc` not found      | Skip sync (script exits gracefully)      |

## Common Mistakes

### Creating worktree from non-default branch

- **Problem:** Worktree diverges from a stale base, not the latest mainline
- **Fix:** Always verify you're on the default branch before creating a worktree

### Not pulling latest changes

- **Problem:** Worktree starts from outdated code, leading to merge conflicts
  later
- **Fix:** Check if default branch is behind origin and prompt to pull

### Proceeding with failing tests

- **Problem:** Can't distinguish new bugs from pre-existing issues
- **Fix:** Report failures, get explicit permission to proceed

### Running project setup before syncing worktreerc

- **Problem:** Setup commands fail because config files (`.env`, etc.) are missing
- **Fix:** Always run the worktreerc sync step before project setup

### Hardcoding setup commands

- **Problem:** Breaks on projects using different tools
- **Fix:** Auto-detect from project files (package.json, etc.)

## Example Workflow

```
You: I'm using the create-git-worktree skill to set up an isolated workspace.

[Verify on default branch (main) - confirmed]
[Fetch origin, compare SHAs - local main is up to date]
[Determine parent dir: /Users/jesse/Code/myproject]
[Sanitize branch name: feature/auth → feature-auth]
[Create worktree: git worktree add /Users/jesse/Code/myproject/feature-auth -b feature/auth]
[Sync worktreerc: copied .env, copied .env.local]
[Run npm install]
[Run npm test - 47 passing]

Worktree ready at /Users/jesse/Code/myproject/feature-auth
Tests passing (47 tests, 0 failures)
Ready to implement auth feature
```

## Red Flags

**Never:**

- Create worktree from a non-default branch
- Skip freshness check against origin
- Run project setup before syncing `.worktreerc` files
- Skip baseline test verification
- Proceed with failing tests without asking
- Leave slashes unsanitized in worktree directory names

**Always:**

- Verify on default branch before creating worktree
- Check if default branch is behind origin
- Sanitize branch names (replace `/` with `-`) for directory paths
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
