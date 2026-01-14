# Claude Code + Git Worktrees: Implementation Plan

## Overview

Implement user-level Claude Code setup with worktree automation, commands, and skills. All files will be tracked via yadm on a new feature branch.

**Branch:** `sal/claude-worktree-setup`
**Base:** `main`

---

## Current State Assessment

### Already Exists
- `~/.oh-my-zsh-custom/` - Numbered zsh files sourced on shell init (01-06 currently)
- `~/.claude.json` - MCP servers (context7, linear, notion, mastra, agno)
- `~/.claude/CLAUDE.md` - Python docstring guidelines
- `~/.claude/commands/dotfiles.md` - Yadm skill
- `~/.claude/settings.json` and `settings.local.json`

### To Create
| File | Purpose |
|------|---------|
| `~/.oh-my-zsh-custom/07_worktree_functions.zsh` | Shell functions: worktree-new, worktree-list, worktree-cleanup |
| `~/.claude/commands/new-worktree.md` | Slash command for worktrees |
| `~/.claude/commands/fix-issue.md` | Fix GitHub issues workflow |
| `~/.claude/commands/pr-review.md` | PR review workflow |
| `~/.claude/commands/cleanup-worktrees.md` | Cleanup slash command |
| `~/.claude/commands/init-project.md` | Project initialization |
| `~/.claude/skills/python-patterns/SKILL.md` | Python best practices |
| `~/.claude/skills/typescript-patterns/SKILL.md` | TS/React patterns |
| `~/.claude/skills/aws-infrastructure/SKILL.md` | AWS/CDK patterns |
| `~/.config/claude-templates/CLAUDE.md.template` | Project template |
| `~/.config/claude-templates/.worktreeinclude.template` | Worktree include template |
| `~/.config/claude-docs/worktree-setup-plan.md` | This plan (for reference) |

### To Modify
| File | Change |
|------|--------|
| `~/.claude.json` | Add GitHub + Sequential Thinking MCP servers |

---

## Implementation Steps

### Step 1: Create Feature Branch
```bash
yadm checkout main
yadm pull
yadm checkout -b sal/claude-worktree-setup
```

### Step 2: Create Directory Structure
```bash
mkdir -p ~/.claude/skills/python-patterns
mkdir -p ~/.claude/skills/typescript-patterns
mkdir -p ~/.claude/skills/aws-infrastructure
mkdir -p ~/.config/claude-docs
mkdir -p ~/.config/claude-templates
```

### Step 3: Create Worktree Functions

#### `~/.oh-my-zsh-custom/07_worktree_functions.zsh`

This file defines shell functions that are sourced on shell init, following the existing convention in `~/.oh-my-zsh-custom/`.

```zsh
# Git worktree helper functions
# These functions help manage git worktrees with automatic environment setup

# Colors for output
_wt_red='\033[0;31m'
_wt_green='\033[0;32m'
_wt_yellow='\033[1;33m'
_wt_blue='\033[0;34m'
_wt_cyan='\033[0;36m'
_wt_dim='\033[2m'
_wt_nc='\033[0m'

# Helper: Get the main repo root (works from any worktree or subdirectory)
_wt_get_repo_root() {
    local git_common_dir
    git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null) || {
        echo -e "${_wt_red}Error: Not in a git repository${_wt_nc}" >&2
        return 1
    }

    if [[ "$git_common_dir" == ".git" ]]; then
        git rev-parse --show-toplevel
    else
        dirname "$git_common_dir"
    fi
}

# Helper: Detect default branch
_wt_get_default_branch() {
    git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || \
    git branch -l main master 2>/dev/null | head -1 | tr -d ' *' || \
    echo "main"
}

# Create a new git worktree with automatic environment setup
worktree-new() {
    local branch_name=""
    local base_branch=""
    local use_existing=false
    local skip_setup=false
    local skip_copy=false
    local no_tmux=false
    local start_claude=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --from)
                base_branch="$2"
                shift 2
                ;;
            --existing)
                use_existing=true
                shift
                ;;
            --no-setup)
                skip_setup=true
                shift
                ;;
            --no-copy)
                skip_copy=true
                shift
                ;;
            --no-tmux)
                no_tmux=true
                shift
                ;;
            --claude)
                start_claude=true
                shift
                ;;
            -h|--help)
                echo -e "${_wt_blue}Usage:${_wt_nc} worktree-new <branch-name> [options]"
                echo ""
                echo "Create a new git worktree with automatic environment setup."
                echo ""
                echo "Options:"
                echo "  --from <branch>    Base branch to create from (default: main or master)"
                echo "  --existing         Use existing branch instead of creating new"
                echo "  --no-setup         Skip environment setup (venv, node_modules)"
                echo "  --no-copy          Skip copying files from .worktreeinclude"
                echo "  --no-tmux          Don't open in new tmux window"
                echo "  --claude           Start Claude Code after setup"
                echo "  -h, --help         Show this help"
                echo ""
                echo "Examples:"
                echo "  worktree-new feature-auth"
                echo "  worktree-new bugfix-123 --existing --claude"
                echo "  worktree-new refactor-api --from develop"
                return 0
                ;;
            -*)
                echo -e "${_wt_red}Error: Unknown option $1${_wt_nc}"
                return 1
                ;;
            *)
                if [[ -z "$branch_name" ]]; then
                    branch_name="$1"
                else
                    echo -e "${_wt_red}Error: Unexpected argument $1${_wt_nc}"
                    return 1
                fi
                shift
                ;;
        esac
    done

    if [[ -z "$branch_name" ]]; then
        echo -e "${_wt_red}Error: Branch name required${_wt_nc}"
        echo "Usage: worktree-new <branch-name> [options]"
        return 1
    fi

    local main_repo=$(_wt_get_repo_root) || return 1
    local repo_name=$(basename "$main_repo")
    local parent_dir=$(dirname "$main_repo")
    local worktree_path="$parent_dir/$branch_name"

    [[ -z "$base_branch" ]] && base_branch=$(_wt_get_default_branch)

    echo -e "${_wt_cyan}╔══════════════════════════════════════════════════════════╗${_wt_nc}"
    echo -e "${_wt_cyan}║  ${_wt_nc}${_wt_blue}Creating Worktree${_wt_nc}"
    echo -e "${_wt_cyan}╠══════════════════════════════════════════════════════════╣${_wt_nc}"
    echo -e "${_wt_cyan}║  ${_wt_nc}Repository: ${_wt_green}$repo_name${_wt_nc}"
    echo -e "${_wt_cyan}║  ${_wt_nc}Branch:     ${_wt_green}$branch_name${_wt_nc}"
    echo -e "${_wt_cyan}║  ${_wt_nc}Base:       ${_wt_green}$base_branch${_wt_nc}"
    echo -e "${_wt_cyan}║  ${_wt_nc}Path:       ${_wt_green}$worktree_path${_wt_nc}"
    echo -e "${_wt_cyan}╚══════════════════════════════════════════════════════════╝${_wt_nc}"
    echo ""

    if [[ -d "$worktree_path" ]]; then
        echo -e "${_wt_yellow}⚠ Worktree already exists at $worktree_path${_wt_nc}"
        echo -e "To use it: ${_wt_blue}cd $worktree_path${_wt_nc}"
        return 1
    fi

    # Create the worktree
    echo -e "${_wt_green}[1/4]${_wt_nc} Creating worktree..."
    if [[ "$use_existing" == true ]]; then
        git worktree add "$worktree_path" "$branch_name" || return 1
    else
        git worktree add "$worktree_path" -b "$branch_name" "$base_branch" || return 1
    fi

    # Copy files from .worktreeinclude
    if [[ "$skip_copy" != true ]]; then
        local include_file="$main_repo/.worktreeinclude"
        if [[ -f "$include_file" ]]; then
            echo -e "${_wt_green}[2/4]${_wt_nc} Copying environment files..."
            local copied=0 skipped=0
            while IFS= read -r line || [[ -n "$line" ]]; do
                [[ "$line" =~ ^[[:space:]]*#.*$ ]] && continue
                [[ -z "${line// }" ]] && continue
                line=$(echo "$line" | xargs)

                local source="$main_repo/$line"
                local dest="$worktree_path/$line"

                if [[ -e "$source" ]]; then
                    mkdir -p "$(dirname "$dest")"
                    if [[ -d "$source" ]]; then
                        cp -R "$source" "$dest"
                    else
                        cp "$source" "$dest"
                    fi
                    ((copied++))
                else
                    ((skipped++))
                fi
            done < "$include_file"
            echo "      Copied: $copied, Skipped: $skipped (not found)"
        else
            echo -e "${_wt_green}[2/4]${_wt_nc} No .worktreeinclude file found, skipping copy"
        fi
    else
        echo -e "${_wt_green}[2/4]${_wt_nc} Skipping file copy (--no-copy)"
    fi

    # Environment setup
    if [[ "$skip_setup" != true ]]; then
        echo -e "${_wt_green}[3/4]${_wt_nc} Setting up environment..."
        (
            cd "$worktree_path" || exit

            # Python setup with uv
            if [[ -f "pyproject.toml" ]] && command -v uv &> /dev/null; then
                if [[ ! -d ".venv" ]]; then
                    echo -e "      Running ${_wt_blue}uv sync${_wt_nc}..."
                    uv sync --quiet 2>/dev/null || echo -e "      ${_wt_yellow}uv sync skipped${_wt_nc}"
                else
                    echo "      Python venv already present"
                fi
            fi

            # Node setup
            if [[ -f "package.json" ]] && [[ ! -d "node_modules" ]]; then
                echo "      Installing Node dependencies..."
                if [[ -f "pnpm-lock.yaml" ]] && command -v pnpm &> /dev/null; then
                    pnpm install --silent 2>/dev/null || true
                elif [[ -f "yarn.lock" ]] && command -v yarn &> /dev/null; then
                    yarn install --silent 2>/dev/null || true
                elif command -v npm &> /dev/null; then
                    npm install --silent 2>/dev/null || true
                fi
            fi
        )
    else
        echo -e "${_wt_green}[3/4]${_wt_nc} Skipping environment setup (--no-setup)"
    fi

    echo -e "${_wt_green}[4/4]${_wt_nc} Finalizing..."
    echo ""
    echo -e "${_wt_green}╔══════════════════════════════════════════════════════════╗${_wt_nc}"
    echo -e "${_wt_green}║  ✓ Worktree created successfully!                        ${_wt_nc}"
    echo -e "${_wt_green}╚══════════════════════════════════════════════════════════╝${_wt_nc}"
    echo ""

    # Tmux integration
    if [[ "$no_tmux" != true ]] && command -v tmux &> /dev/null && [[ -n "${TMUX:-}" ]]; then
        local window_name="${repo_name}:${branch_name}"
        if [[ "$start_claude" == true ]]; then
            tmux new-window -n "$window_name" -c "$worktree_path" "claude"
            echo -e "Opened in tmux window ${_wt_blue}$window_name${_wt_nc} with Claude Code"
        else
            tmux new-window -n "$window_name" -c "$worktree_path"
            echo -e "Opened in tmux window ${_wt_blue}$window_name${_wt_nc}"
            echo -e "Run ${_wt_blue}claude${_wt_nc} to start Claude Code"
        fi
    else
        echo "Next steps:"
        echo -e "  ${_wt_blue}cd $worktree_path${_wt_nc}"
        echo -e "  ${_wt_blue}claude${_wt_nc}"
    fi
}

# List all worktrees with status information
worktree-list() {
    if ! git rev-parse --git-dir &>/dev/null; then
        echo -e "${_wt_red}Error: Not in a git repository${_wt_nc}"
        return 1
    fi

    local repo_name=$(basename "$(git rev-parse --git-common-dir | xargs dirname)")

    echo -e "${_wt_cyan}╔══════════════════════════════════════════════════════════╗${_wt_nc}"
    echo -e "${_wt_cyan}║  ${_wt_nc}${_wt_blue}Worktrees for: $repo_name${_wt_nc}"
    echo -e "${_wt_cyan}╚══════════════════════════════════════════════════════════╝${_wt_nc}"
    echo ""

    local worktree_path="" branch="" is_bare=false

    git worktree list --porcelain | while read -r line; do
        if [[ "$line" == worktree* ]]; then
            worktree_path="${line#worktree }"
        elif [[ "$line" == "bare" ]]; then
            is_bare=true
        elif [[ "$line" == branch* ]]; then
            branch="${line#branch refs/heads/}"
        elif [[ -z "$line" ]]; then
            [[ "$is_bare" == true ]] && { is_bare=false; continue; }
            [[ -z "$worktree_path" ]] && continue

            local worktree_name=$(basename "$worktree_path")
            local status sync_status

            if [[ -d "$worktree_path" ]]; then
                (
                    cd "$worktree_path" 2>/dev/null || exit

                    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
                        status="${_wt_yellow}●${_wt_nc} uncommitted changes"
                    else
                        status="${_wt_green}✓${_wt_nc} clean"
                    fi

                    local ahead_behind=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null || echo "- -")
                    local ahead=$(echo "$ahead_behind" | awk '{print $1}')
                    local behind=$(echo "$ahead_behind" | awk '{print $2}')

                    sync_status=""
                    if [[ "$ahead" != "-" ]]; then
                        [[ "$ahead" -gt 0 ]] && sync_status+="${_wt_green}↑$ahead${_wt_nc} "
                        [[ "$behind" -gt 0 ]] && sync_status+="${_wt_red}↓$behind${_wt_nc}"
                    else
                        sync_status="${_wt_dim}(no upstream)${_wt_nc}"
                    fi

                    echo -e "${_wt_green}$worktree_name${_wt_nc}"
                    echo -e "  Branch: ${_wt_blue}$branch${_wt_nc} $sync_status"
                    echo -e "  Path:   ${_wt_dim}$worktree_path${_wt_nc}"
                    echo -e "  Status: $status"
                    echo ""
                )
            else
                echo -e "${_wt_green}$worktree_name${_wt_nc}"
                echo -e "  Branch: ${_wt_blue}$branch${_wt_nc}"
                echo -e "  Path:   ${_wt_dim}$worktree_path${_wt_nc}"
                echo -e "  Status: ${_wt_red}✗${_wt_nc} directory missing"
                echo ""
            fi

            worktree_path="" branch=""
        fi
    done
}

# Clean up merged worktrees and branches
worktree-cleanup() {
    if ! git rev-parse --git-dir &>/dev/null; then
        echo -e "${_wt_red}Error: Not in a git repository${_wt_nc}"
        return 1
    fi

    local main_repo=$(git rev-parse --git-common-dir | xargs dirname)
    cd "$main_repo" || return 1

    local default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

    echo -e "${_wt_cyan}╔══════════════════════════════════════════════════════════╗${_wt_nc}"
    echo -e "${_wt_cyan}║  ${_wt_nc}${_wt_blue}Worktree Cleanup${_wt_nc}"
    echo -e "${_wt_cyan}╠══════════════════════════════════════════════════════════╣${_wt_nc}"
    echo -e "${_wt_cyan}║  ${_wt_nc}Default branch: ${_wt_green}$default_branch${_wt_nc}"
    echo -e "${_wt_cyan}╚══════════════════════════════════════════════════════════╝${_wt_nc}"
    echo ""

    echo -e "${_wt_dim}Fetching latest from remote...${_wt_nc}"
    git fetch --prune --quiet

    local merged_branches=$(git branch --merged "$default_branch" | grep -v "^\*" | grep -v "$default_branch" | grep -v "HEAD" | tr -d ' ' || true)

    if [[ -z "$merged_branches" ]]; then
        echo -e "${_wt_green}✓ No merged branches to clean up.${_wt_nc}"
        return 0
    fi

    echo -e "${_wt_yellow}Branches merged into $default_branch:${_wt_nc}"
    echo ""

    local -a worktrees_to_remove=()
    local -a branches_to_delete=()

    while IFS= read -r branch; do
        [[ -z "$branch" ]] && continue

        local wt_path=$(git worktree list --porcelain | grep -B2 "branch refs/heads/$branch$" | grep "^worktree" | cut -d' ' -f2 || true)

        if [[ -n "$wt_path" ]]; then
            echo -e "  ${_wt_blue}$branch${_wt_nc}"
            echo -e "    └─ Worktree: ${_wt_dim}$wt_path${_wt_nc}"
            worktrees_to_remove+=("$wt_path")
        else
            echo -e "  ${_wt_blue}$branch${_wt_nc} ${_wt_dim}(no worktree)${_wt_nc}"
        fi
        branches_to_delete+=("$branch")
    done <<< "$merged_branches"

    echo ""
    echo -e "Will remove ${_wt_yellow}${#worktrees_to_remove[@]}${_wt_nc} worktree(s) and ${_wt_yellow}${#branches_to_delete[@]}${_wt_nc} branch(es)"
    echo ""

    read -q "REPLY?Proceed? (y/N) "
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""

        for wt_path in "${worktrees_to_remove[@]}"; do
            echo -e "${_wt_green}→${_wt_nc} Removing worktree: $wt_path"
            git worktree remove "$wt_path" --force 2>/dev/null || {
                echo -e "  ${_wt_yellow}⚠ Could not remove, trying force...${_wt_nc}"
                rm -rf "$wt_path" 2>/dev/null || true
            }
        done

        for branch in "${branches_to_delete[@]}"; do
            echo -e "${_wt_green}→${_wt_nc} Deleting branch: $branch"
            git branch -d "$branch" 2>/dev/null || {
                echo -e "  ${_wt_yellow}⚠ Branch may have been deleted already${_wt_nc}"
            }
        done

        git worktree prune
        echo ""
        echo -e "${_wt_green}✓ Cleanup complete${_wt_nc}"
    else
        echo -e "${_wt_yellow}Cleanup cancelled.${_wt_nc}"
    fi
}
```

### Step 4: Create Claude Commands

#### `~/.claude/commands/new-worktree.md`
```markdown
# Create New Worktree

Create a new git worktree for parallel development.

## Usage

```
/user:new-worktree <branch-name> [options]
```

## Options

- `--from <branch>` - Base branch (default: main/master)
- `--existing` - Use existing branch
- `--no-setup` - Skip environment setup
- `--claude` - Start Claude Code in new tmux window

## Process

Run the worktree creation script:

```bash
worktree-new $ARGUMENTS
```

Report the result with the new worktree path and next steps.

## Examples

### Basic feature branch
```
/user:new-worktree feature-user-auth
```

### From existing branch with Claude
```
/user:new-worktree bugfix-jwt --existing --claude
```

### From develop branch
```
/user:new-worktree feature-api --from develop
```
```

#### `~/.claude/commands/fix-issue.md`
```markdown
# Fix GitHub Issue

Analyze and fix a GitHub issue with proper workflow.

## Usage

```
/user:fix-issue <issue-number>
```

## Process

1. **Fetch issue details:**
   ```bash
   gh issue view <issue-number> --json title,body,labels,comments
   ```

2. **Analyze the issue:**
   - Understand the problem described
   - Identify affected areas of codebase
   - Check for related issues or PRs

3. **Search codebase:**
   - Find relevant files using grep/ripgrep
   - Understand current implementation
   - Identify test files

4. **Plan the fix:**
   - For simple bugs: proceed with implementation
   - For complex changes: present plan and wait for approval

5. **Implement:**
   - Make minimal, focused changes
   - Follow project coding standards (check CLAUDE.md)
   - Add or update tests

6. **Verify:**
   - Run the project's test suite
   - Run linters if configured
   - Check types if applicable

7. **Create commit:**
   - Use conventional commit format
   - Reference issue number: `fix: resolve login timeout (#123)`

8. **Create PR:**
   ```bash
   gh pr create --title "Fix: <issue-title>" --body "Fixes #<issue-number>"
   ```

## Examples

### Simple bug fix
```
/user:fix-issue 1234
```

### Complex issue
```
/user:fix-issue 5678
```
For complex issues, I'll first present my analysis and proposed approach before implementing.
```

#### `~/.claude/commands/pr-review.md`
```markdown
# Review Pull Request

Perform a thorough code review of a pull request.

## Usage

```
/user:pr-review <pr-number>
```

## Process

1. **Fetch PR details:**
   ```bash
   gh pr view <pr-number> --json title,body,files,commits,additions,deletions
   gh pr diff <pr-number>
   ```

2. **Review checklist:**
   - [ ] Code follows project standards
   - [ ] Changes match PR description
   - [ ] Tests added/updated appropriately
   - [ ] No security vulnerabilities introduced
   - [ ] No performance regressions
   - [ ] Documentation updated if needed

3. **Analyze changes:**
   - Review each modified file
   - Verify logic correctness
   - Look for edge cases
   - Check error handling

4. **Provide feedback** in this format:

```markdown
## PR Review: #<number> - <title>

### Summary
<brief overview of changes>

### Issues Found
- **file.py:42** - <issue description>
- **component.tsx:18** - <issue description>

### Suggestions
- Consider <improvement>

### What's Good
- <positive observations>

### Verdict
<APPROVE | REQUEST_CHANGES | COMMENT>

<reasoning for verdict>
```
```

#### `~/.claude/commands/cleanup-worktrees.md`
```markdown
# Cleanup Worktrees

Remove worktrees for branches that have been merged.

## Usage

```
/user:cleanup-worktrees
```

## Process

1. **List current worktrees:**
   ```bash
   worktree-list
   ```

2. **Run cleanup script:**
   ```bash
   worktree-cleanup
   ```

3. **Report results:**
   - Which worktrees were removed
   - Which branches were deleted
   - Any errors encountered

## Notes

- Only removes worktrees for branches merged into the default branch (main/master)
- Requires confirmation before deletion
- Will not remove worktrees with uncommitted changes without force
```

#### `~/.claude/commands/init-project.md`
```markdown
# Initialize Project for Claude Code

Set up a project with Claude Code best practices.

## Usage

```
/user:init-project
```

## Process

1. **Check for existing files:**
   - CLAUDE.md
   - .worktreeinclude
   - .claude/ directory

2. **Create .worktreeinclude** if it doesn't exist:
   ```
   # Python
   .venv
   .python-version

   # Node
   node_modules

   # IDE
   .idea
   .vscode

   # Environment
   .env
   .env.local
   .env.development
   ```

3. **Create CLAUDE.md** if it doesn't exist:
   - Detect project type (Python, Node, both)
   - Add appropriate commands section
   - Add coding standards
   - Reference global skills

4. **Create .claude/settings.local.json** for any project-specific overrides

5. **Report what was created** and suggest next steps

## What Gets Created

- `CLAUDE.md` - Project memory with detected tech stack
- `.worktreeinclude` - Files to copy to worktrees
- `.gitignore` additions if needed
```

### Step 5: Create Skills

#### `~/.claude/skills/python-patterns/SKILL.md`
```markdown
---
name: python-patterns
description: Python development patterns for data engineering and API development. Use when writing Python code, especially for data processing with Polars/PySpark, async operations, or FastAPI endpoints.
---

# Python Patterns

## Polars over Pandas

```python
# ✅ Polars - lazy evaluation, better performance
import polars as pl

df = (
    pl.scan_parquet("data/*.parquet")
    .filter(pl.col("date") >= "2024-01-01")
    .group_by("category")
    .agg([
        pl.col("amount").sum().alias("total"),
        pl.col("id").n_unique().alias("unique_ids")
    ])
    .collect()
)

# ❌ Pandas - eager, memory issues with large data
import pandas as pd
df = pd.read_parquet("data/")  # Loads everything into memory
```

## Type Hints

```python
# ✅ Full type hints with modern syntax (Python 3.10+)
from collections.abc import Callable, Iterable, Sequence

def process_items[T, R](
    items: Iterable[T],
    transform: Callable[[T], R],
    batch_size: int = 100
) -> list[R]:
    results: list[R] = []
    for batch in batched(items, batch_size):
        results.extend(transform(item) for item in batch)
    return results
```

## Async Patterns

```python
# ✅ Concurrent execution with proper error handling
import asyncio
from httpx import AsyncClient

async def fetch_all(urls: list[str]) -> list[dict]:
    async with AsyncClient(timeout=30.0) as client:
        tasks = [client.get(url) for url in urls]
        responses = await asyncio.gather(*tasks, return_exceptions=True)
        return [
            r.json() if not isinstance(r, Exception) else {"error": str(r), "url": url}
            for r, url in zip(responses, urls)
        ]

# ✅ Semaphore for rate limiting
async def fetch_with_limit(urls: list[str], max_concurrent: int = 10):
    semaphore = asyncio.Semaphore(max_concurrent)

    async def fetch_one(url: str):
        async with semaphore:
            async with AsyncClient() as client:
                return await client.get(url)

    return await asyncio.gather(*[fetch_one(url) for url in urls])
```

## FastAPI Patterns

```python
# ✅ Dependency injection with proper typing
from typing import Annotated
from collections.abc import AsyncGenerator
from fastapi import Depends, HTTPException, status

async def get_db() -> AsyncGenerator[Database, None]:
    db = await Database.connect()
    try:
        yield db
    finally:
        await db.close()

DB = Annotated[Database, Depends(get_db)]

@router.get("/items/{item_id}", response_model=ItemResponse)
async def get_item(item_id: str, db: DB) -> Item:
    item = await db.items.get(item_id)
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Item {item_id} not found"
        )
    return item
```

## Pydantic Models

```python
# ✅ Pydantic v2 patterns
from pydantic import BaseModel, Field, field_validator, ConfigDict

class OrderRequest(BaseModel):
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)

    product_id: str = Field(..., pattern=r"^PROD-\d{6}$")
    quantity: int = Field(..., ge=1, le=100)
    notes: str | None = Field(None, max_length=500)

    @field_validator("product_id")
    @classmethod
    def validate_product_id(cls, v: str) -> str:
        return v.upper()
```

## Dataclasses for Internal Data

```python
# ✅ Frozen dataclasses for immutable internal data
from dataclasses import dataclass, field
from datetime import datetime

@dataclass(frozen=True, slots=True)
class OrderResult:
    order_id: str
    status: str
    items: tuple[str, ...]  # Use tuple for immutability
    created_at: datetime = field(default_factory=datetime.now)
```

## Error Handling

```python
# ✅ Specific exceptions with context
class OrderError(Exception):
    def __init__(self, order_id: str, message: str):
        self.order_id = order_id
        super().__init__(f"Order {order_id}: {message}")

class InsufficientInventory(OrderError):
    def __init__(self, order_id: str, product_id: str, available: int, requested: int):
        self.product_id = product_id
        self.available = available
        self.requested = requested
        super().__init__(
            order_id,
            f"Need {requested} of {product_id}, only {available} available"
        )
```

## Context Efficiency Pattern

When processing data, return summaries instead of raw data:

```python
# ✅ Process and summarize - return only what's needed
from collections import Counter
from pathlib import Path

def analyze_logs(log_dir: Path) -> dict:
    errors = []
    for log_file in log_dir.glob("*.log"):
        content = log_file.read_text()
        errors.extend(parse_errors(content))

    return {
        "total_errors": len(errors),
        "by_type": dict(Counter(e.type for e in errors)),
        "critical": [
            {"file": e.file, "line": e.line, "message": e.message}
            for e in errors if e.severity == "critical"
        ][:10]  # Limit output
    }

# ❌ Don't return raw log contents
```
```

#### `~/.claude/skills/typescript-patterns/SKILL.md`
```markdown
---
name: typescript-patterns
description: TypeScript and React patterns for frontend development. Use when writing React components, hooks, or TypeScript utilities, especially with Ant Design.
---

# TypeScript Patterns

## React Component Structure

```tsx
// ✅ Well-structured component with proper typing
import { useState, useCallback, useMemo } from 'react';
import { Table, Button, Space, message } from 'antd';
import type { ColumnsType } from 'antd/es/table';

interface User {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'user' | 'guest';
}

interface UserTableProps {
  users: User[];
  onDelete?: (userId: string) => Promise<void>;
  loading?: boolean;
}

export function UserTable({
  users,
  onDelete,
  loading = false
}: UserTableProps) {
  const [deletingId, setDeletingId] = useState<string | null>(null);

  const handleDelete = useCallback(async (userId: string) => {
    if (!onDelete) return;

    setDeletingId(userId);
    try {
      await onDelete(userId);
      message.success('User deleted');
    } catch (error) {
      message.error('Failed to delete user');
    } finally {
      setDeletingId(null);
    }
  }, [onDelete]);

  const columns = useMemo<ColumnsType<User>>(() => [
    {
      title: 'Name',
      dataIndex: 'name',
      sorter: (a, b) => a.name.localeCompare(b.name)
    },
    { title: 'Email', dataIndex: 'email' },
    {
      title: 'Role',
      dataIndex: 'role',
      filters: [
        { text: 'Admin', value: 'admin' },
        { text: 'User', value: 'user' },
        { text: 'Guest', value: 'guest' },
      ],
      onFilter: (value, record) => record.role === value,
    },
    {
      title: 'Actions',
      key: 'actions',
      render: (_, record) => (
        <Space>
          <Button
            danger
            size="small"
            loading={deletingId === record.id}
            onClick={() => handleDelete(record.id)}
            disabled={!onDelete}
          >
            Delete
          </Button>
        </Space>
      ),
    },
  ], [deletingId, handleDelete, onDelete]);

  return (
    <Table
      columns={columns}
      dataSource={users}
      rowKey="id"
      loading={loading}
      pagination={{ pageSize: 10 }}
    />
  );
}
```

## Custom Hooks

```tsx
// ✅ Data fetching hook with proper state management
import { useState, useEffect, useCallback, useRef } from 'react';

interface AsyncState<T> {
  data: T | null;
  loading: boolean;
  error: Error | null;
}

interface UseAsyncResult<T> extends AsyncState<T> {
  refetch: () => Promise<void>;
}

export function useAsync<T>(
  asyncFn: () => Promise<T>,
  deps: unknown[] = []
): UseAsyncResult<T> {
  const [state, setState] = useState<AsyncState<T>>({
    data: null,
    loading: true,
    error: null,
  });

  // Track if component is mounted
  const mountedRef = useRef(true);

  useEffect(() => {
    mountedRef.current = true;
    return () => { mountedRef.current = false; };
  }, []);

  const execute = useCallback(async () => {
    setState(prev => ({ ...prev, loading: true, error: null }));
    try {
      const data = await asyncFn();
      if (mountedRef.current) {
        setState({ data, loading: false, error: null });
      }
    } catch (error) {
      if (mountedRef.current) {
        setState({ data: null, loading: false, error: error as Error });
      }
    }
  }, deps);

  useEffect(() => {
    execute();
  }, [execute]);

  return { ...state, refetch: execute };
}
```

## Type Utilities

```typescript
// ✅ Useful type helpers
type Nullable<T> = T | null | undefined;

type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};

type AsyncReturnType<T extends (...args: unknown[]) => Promise<unknown>> =
  T extends (...args: unknown[]) => Promise<infer R> ? R : never;

// ✅ Discriminated unions for results
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

function isSuccess<T, E>(result: Result<T, E>): result is { success: true; data: T } {
  return result.success;
}

// ✅ Exhaustive switch helper
function assertNever(x: never): never {
  throw new Error(`Unexpected value: ${x}`);
}
```

## Ant Design Form Patterns

```tsx
// ✅ Typed form with validation
import { Form, Input, Select, Button, message } from 'antd';
import type { Rule } from 'antd/es/form';

interface CreateUserForm {
  name: string;
  email: string;
  role: 'admin' | 'user';
}

const rules: Record<keyof CreateUserForm, Rule[]> = {
  name: [
    { required: true, message: 'Name is required' },
    { min: 2, message: 'Name must be at least 2 characters' },
    { max: 50, message: 'Name must be at most 50 characters' },
  ],
  email: [
    { required: true, message: 'Email is required' },
    { type: 'email', message: 'Please enter a valid email' },
  ],
  role: [{ required: true, message: 'Role is required' }],
};

interface CreateUserFormProps {
  onSubmit: (values: CreateUserForm) => Promise<void>;
  initialValues?: Partial<CreateUserForm>;
}

export function CreateUserForm({ onSubmit, initialValues }: CreateUserFormProps) {
  const [form] = Form.useForm<CreateUserForm>();
  const [loading, setLoading] = useState(false);

  const handleFinish = async (values: CreateUserForm) => {
    setLoading(true);
    try {
      await onSubmit(values);
      form.resetFields();
      message.success('User created successfully');
    } catch (error) {
      message.error('Failed to create user');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Form
      form={form}
      layout="vertical"
      onFinish={handleFinish}
      initialValues={initialValues}
    >
      <Form.Item name="name" label="Name" rules={rules.name}>
        <Input placeholder="Enter name" />
      </Form.Item>

      <Form.Item name="email" label="Email" rules={rules.email}>
        <Input type="email" placeholder="Enter email" />
      </Form.Item>

      <Form.Item name="role" label="Role" rules={rules.role}>
        <Select
          placeholder="Select role"
          options={[
            { label: 'Admin', value: 'admin' },
            { label: 'User', value: 'user' },
          ]}
        />
      </Form.Item>

      <Form.Item>
        <Button type="primary" htmlType="submit" loading={loading}>
          Create User
        </Button>
      </Form.Item>
    </Form>
  );
}
```

## API Service Pattern

```typescript
// ✅ Type-safe API service
const API_BASE = '/api/v1';

async function fetchJSON<T>(
  endpoint: string,
  options?: RequestInit
): Promise<T> {
  const response = await fetch(`${API_BASE}${endpoint}`, {
    headers: {
      'Content-Type': 'application/json',
      ...options?.headers,
    },
    ...options,
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(error.message || `HTTP ${response.status}`);
  }

  return response.json();
}

// Usage
interface User {
  id: string;
  name: string;
}

const userService = {
  list: () => fetchJSON<User[]>('/users'),
  get: (id: string) => fetchJSON<User>(`/users/${id}`),
  create: (data: Omit<User, 'id'>) =>
    fetchJSON<User>('/users', {
      method: 'POST',
      body: JSON.stringify(data),
    }),
};
```
```

#### `~/.claude/skills/aws-infrastructure/SKILL.md`
```markdown
---
name: aws-infrastructure
description: AWS infrastructure patterns for data engineering. Use when working with EMR Serverless, Glue, Athena, CDK, or Iceberg tables.
---

# AWS Infrastructure Patterns

## EMR Serverless Job Submission

```python
# ✅ Standard PySpark job with monitoring
import boto3
from datetime import datetime

def submit_emr_job(
    app_id: str,
    role_arn: str,
    script_path: str,
    args: list[str] | None = None,
    spark_config: dict | None = None,
) -> str:
    client = boto3.client("emr-serverless")

    # Default Spark configuration
    default_config = {
        "spark.executor.memory": "4G",
        "spark.executor.cores": "2",
        "spark.dynamicAllocation.enabled": "true",
        "spark.dynamicAllocation.minExecutors": "1",
        "spark.dynamicAllocation.maxExecutors": "10",
    }
    config = {**default_config, **(spark_config or {})}

    spark_params = " ".join(f"--conf {k}={v}" for k, v in config.items())

    response = client.start_job_run(
        applicationId=app_id,
        executionRoleArn=role_arn,
        jobDriver={
            "sparkSubmit": {
                "entryPoint": script_path,
                "entryPointArguments": args or [],
                "sparkSubmitParameters": spark_params,
            }
        },
        configurationOverrides={
            "monitoringConfiguration": {
                "s3MonitoringConfiguration": {
                    "logUri": f"s3://logs-bucket/emr/{datetime.now():%Y/%m/%d}/"
                }
            }
        },
        tags={"submitted_at": datetime.now().isoformat()},
    )

    return response["jobRunId"]
```

## Iceberg Table Operations

```python
# ✅ Spark session with Iceberg and Glue catalog
from pyspark.sql import SparkSession

def get_spark_session(app_name: str = "iceberg-app") -> SparkSession:
    return SparkSession.builder \
        .appName(app_name) \
        .config("spark.sql.catalog.glue_catalog", "org.apache.iceberg.spark.SparkCatalog") \
        .config("spark.sql.catalog.glue_catalog.warehouse", "s3://warehouse-bucket/") \
        .config("spark.sql.catalog.glue_catalog.catalog-impl", "org.apache.iceberg.aws.glue.GlueCatalog") \
        .config("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions") \
        .getOrCreate()

# ✅ Reading with partition pruning (happens automatically)
spark = get_spark_session()
df = spark.read.format("iceberg") \
    .load("glue_catalog.database.my_table") \
    .filter("date >= '2024-01-01' AND region = 'us-west-2'")

# ✅ MERGE INTO for upserts
spark.sql("""
    MERGE INTO glue_catalog.database.target t
    USING glue_catalog.database.updates u
    ON t.id = u.id
    WHEN MATCHED THEN UPDATE SET *
    WHEN NOT MATCHED THEN INSERT *
""")

# ✅ Table maintenance
spark.sql("CALL glue_catalog.system.expire_snapshots('db.table', TIMESTAMP '2024-01-01 00:00:00')")
spark.sql("CALL glue_catalog.system.rewrite_data_files('db.table')")
spark.sql("CALL glue_catalog.system.rewrite_manifests('db.table')")
```

## Athena Async Queries

```python
# ✅ Athena query execution with pagination
import boto3
from typing import Iterator

def run_athena_query(
    query: str,
    database: str,
    output_location: str,
    timeout: int = 300,
) -> str:
    athena = boto3.client("athena")

    response = athena.start_query_execution(
        QueryString=query,
        QueryExecutionContext={"Database": database},
        ResultConfiguration={"OutputLocation": output_location},
    )

    execution_id = response["QueryExecutionId"]

    # Wait for completion
    import time
    start = time.time()
    while True:
        result = athena.get_query_execution(QueryExecutionId=execution_id)
        state = result["QueryExecution"]["Status"]["State"]

        if state == "SUCCEEDED":
            return execution_id
        elif state in ("FAILED", "CANCELLED"):
            reason = result["QueryExecution"]["Status"].get("StateChangeReason", "Unknown")
            raise Exception(f"Query {state}: {reason}")

        if time.time() - start > timeout:
            athena.stop_query_execution(QueryExecutionId=execution_id)
            raise TimeoutError(f"Query timed out after {timeout}s")

        time.sleep(2)

def get_athena_results(execution_id: str) -> Iterator[dict]:
    athena = boto3.client("athena")
    paginator = athena.get_paginator("get_query_results")

    columns = None
    for page in paginator.paginate(QueryExecutionId=execution_id):
        result_set = page["ResultSet"]

        if columns is None:
            columns = [col["Name"] for col in result_set["ResultSetMetadata"]["ColumnInfo"]]
            rows = result_set["Rows"][1:]  # Skip header
        else:
            rows = result_set["Rows"]

        for row in rows:
            values = [field.get("VarCharValue") for field in row["Data"]]
            yield dict(zip(columns, values))
```

## CDK Stack Pattern

```python
# ✅ Well-structured CDK stack
from aws_cdk import (
    Stack,
    RemovalPolicy,
    Tags,
    Duration,
    aws_s3 as s3,
    aws_glue as glue,
    aws_iam as iam,
    aws_lambda as lambda_,
)
from constructs import Construct

class DataPipelineStack(Stack):
    def __init__(
        self,
        scope: Construct,
        id: str,
        env_name: str,
        **kwargs
    ) -> None:
        super().__init__(scope, id, **kwargs)

        prefix = f"{env_name}-pipeline"

        # Data bucket with lifecycle rules
        self.data_bucket = s3.Bucket(
            self, "DataBucket",
            bucket_name=f"{prefix}-data-{self.account}",
            removal_policy=RemovalPolicy.RETAIN,
            versioned=True,
            encryption=s3.BucketEncryption.S3_MANAGED,
            block_public_access=s3.BlockPublicAccess.BLOCK_ALL,
            lifecycle_rules=[
                s3.LifecycleRule(
                    id="archive-old-data",
                    transitions=[
                        s3.Transition(
                            storage_class=s3.StorageClass.INTELLIGENT_TIERING,
                            transition_after=Duration.days(90),
                        )
                    ],
                ),
            ],
        )

        # Glue database
        self.database = glue.CfnDatabase(
            self, "Database",
            catalog_id=self.account,
            database_input=glue.CfnDatabase.DatabaseInputProperty(
                name=f"{prefix.replace('-', '_')}_db",
                description=f"Database for {env_name} data pipeline",
            ),
        )

        # Apply standard tags
        Tags.of(self).add("Environment", env_name)
        Tags.of(self).add("Project", "DataPipeline")
        Tags.of(self).add("ManagedBy", "CDK")
```
```

### Step 6: Create Templates

#### `~/.config/claude-templates/CLAUDE.md.template`
```markdown
# Project: {{PROJECT_NAME}}

## Quick Reference

- **Language:** {{LANGUAGES}}
- **Package Manager:** {{PACKAGE_MANAGERS}}
- **Testing:** {{TEST_FRAMEWORKS}}
- **Linting:** {{LINTERS}}

## Project Structure

```
{{PROJECT_STRUCTURE}}
```

## Development Commands

```bash
{{DEV_COMMANDS}}
```

## Coding Standards

Follow the global skills for language-specific patterns:
- Python: `~/.claude/skills/python-patterns/`
- TypeScript: `~/.claude/skills/typescript-patterns/`
- AWS: `~/.claude/skills/aws-infrastructure/`

### Project-Specific Standards

{{PROJECT_STANDARDS}}

## Tool Usage Patterns

### Batch Operations

When working with multiple files/resources, write code to process in batches:

```python
# ✅ Batch processing - efficient
results = await asyncio.gather(*[process(item) for item in items])
summary = {"total": len(items), "success": sum(1 for r in results if r.ok)}

# ❌ One-by-one - inefficient
# Don't request each item separately
```

### Context Efficiency

- Use `git diff --stat` before full diffs
- Summarize large outputs rather than showing everything
- For data processing, show aggregates not raw data

## Git Workflow

1. Create worktree: `worktree-new feature-name --claude`
2. Develop in isolated environment
3. Create PR when ready
4. After merge: `worktree-cleanup`

## Project-Specific Notes

{{PROJECT_NOTES}}
```

#### `~/.config/claude-templates/.worktreeinclude.template`
```
# Python
.venv
.python-version

# Node
node_modules

# IDE
.idea
.vscode

# Environment files
.env
.env.local
.env.development
.env.test

# Add project-specific files below:
```

### Step 7: Update MCP Configuration

Merge new MCP servers into existing `~/.claude.json` mcpServers section:
```json
"github": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-github"],
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
  }
},
"sequential-thinking": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
}
```

### Step 8: Save Plan for Reference

Copy finalized plan to `~/.config/claude-docs/worktree-setup-plan.md`

### Step 9: Stage and Commit

```bash
yadm add ~/.oh-my-zsh-custom/07_worktree_functions.zsh
yadm add ~/.claude/commands/new-worktree.md
yadm add ~/.claude/commands/fix-issue.md
yadm add ~/.claude/commands/pr-review.md
yadm add ~/.claude/commands/cleanup-worktrees.md
yadm add ~/.claude/commands/init-project.md
yadm add ~/.claude/skills/
yadm add ~/.config/claude-docs/
yadm add ~/.config/claude-templates/
# Note: ~/.claude.json likely gitignored (contains project data)

yadm commit -m "Add Claude Code worktree automation and skills"
yadm push -u origin HEAD
```

---

## Files NOT to Track

These contain dynamic/sensitive data and should remain untracked:
- `~/.claude.json` (43KB, contains project history and session data)
- `~/.claude/projects/`
- `~/.claude/debug/`
- `~/.claude/downloads/`
- `~/.claude/history.jsonl`

---

## Verification

After implementation:
1. `source ~/.oh-my-zsh-custom/07_worktree_functions.zsh` - Source the new functions
2. `worktree-new --help` - Shows usage
3. `worktree-list` - Lists worktrees from any git repo
4. In Claude Code: `/user:new-worktree test` - Command available
5. Skills load when discussing Python/TS/AWS code
6. `yadm status` - All files staged correctly
7. `/mcp` shows github and sequential-thinking servers

---

## File Count Summary

**New files to create:** 12
- 1 zsh functions file (`~/.oh-my-zsh-custom/07_worktree_functions.zsh`)
- 5 commands (`~/.claude/commands/`)
- 3 skills (`~/.claude/skills/*/SKILL.md`)
- 2 templates (`~/.config/claude-templates/`)
- 1 reference doc (`~/.config/claude-docs/`)

**Files to modify:** 1
- `~/.claude.json` (add 2 MCP servers)
