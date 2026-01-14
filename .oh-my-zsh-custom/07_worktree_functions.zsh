# Git worktree helpers

_wt_root() {
    local d=$(git rev-parse --git-common-dir 2>/dev/null) || return 1
    [[ "$d" == ".git" ]] && git rev-parse --show-toplevel || dirname "$d"
}

_wt_default_branch() {
    command git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | command sed 's@^refs/remotes/origin/@@' || echo main
}

# Create worktree: wt-new <branch> [base-branch] [--existing]
wt-new() {
    local wt_branch="" wt_base="" wt_existing=false
    for arg in "$@"; do
        case "$arg" in
            --existing) wt_existing=true ;;
            -*)
                echo "Unknown option: $arg"
                return 1
                ;;
            *) [[ -z "$wt_branch" ]] && wt_branch="$arg" || wt_base="$arg" ;;
        esac
    done

    [[ -z "$wt_branch" ]] && {
        echo "Usage: wt-new <branch> [base] [--existing]"
        return 1
    }

    local wt_repo
    wt_repo=$(_wt_root) || {
        echo "Not in a git repo"
        return 1
    }

    local wt_path="$(dirname "$wt_repo")/$wt_branch"
    [[ -d "$wt_path" ]] && {
        echo "Exists: $wt_path"
        return 1
    }

    [[ -z "$wt_base" ]] && wt_base=$(_wt_default_branch)

    if $wt_existing; then
        git worktree add "$wt_path" "$wt_branch"
    else
        git worktree add "$wt_path" -b "$wt_branch" "$wt_base"
    fi || return 1

    if [[ -n "$TMUX" ]]; then
        tmux new-window -n "$wt_branch" -c "$wt_path"
        echo "Opened tmux window: $wt_branch"
    else
        echo "cd $wt_path"
    fi
}

# List worktrees with dirty status
wt-list() {
    local wt_path="" wt_branch="" wt_status=""
    git worktree list --porcelain | while read -r line; do
        [[ "$line" == worktree* ]] && wt_path="${line#worktree }"
        [[ "$line" == branch* ]] && wt_branch="${line#branch refs/heads/}"
        if [[ -z "$line" && -n "$wt_path" ]]; then
            wt_status="clean"
            [[ -n $(git -C "$wt_path" status --porcelain 2>/dev/null) ]] && wt_status="dirty"
            printf "%-30s %-20s [%s]\n" "$(basename "$wt_path")" "$wt_branch" "$wt_status"
            wt_path="" wt_branch=""
        fi
    done
}

# Prune stale worktrees and show merged branches
wt-cleanup() {
    git worktree prune
    echo "Pruned stale worktrees."
    local default=$(_wt_default_branch)
    local merged=$(git branch --merged "$default" 2>/dev/null | grep -vE "^\*|^[[:space:]]*${default}$")
    if [[ -n "$merged" ]]; then
        echo "Merged branches:"
        echo "$merged"
    else
        echo "No merged branches."
    fi
}
