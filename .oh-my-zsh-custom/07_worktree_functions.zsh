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
