# Git worktree helpers

_wt_root() {
    local d=$(git rev-parse --git-common-dir 2>/dev/null) || return 1
    [[ "$d" == ".git" ]] && git rev-parse --show-toplevel || dirname "$d"
}

_wt_default_branch() {
    git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo main
}

# Create worktree: wt-new <branch> [base-branch] [--existing]
wt-new() {
    local branch="" base="" existing=false
    for arg in "$@"; do
        case "$arg" in
            --existing) existing=true ;;
            -*) echo "Unknown option: $arg"; return 1 ;;
            *) [[ -z "$branch" ]] && branch="$arg" || base="$arg" ;;
        esac
    done

    [[ -z "$branch" ]] && { echo "Usage: wt-new <branch> [base] [--existing]"; return 1; }
    local repo=$(_wt_root) || { echo "Not in a git repo"; return 1; }
    local path="$(dirname "$repo")/$branch"
    [[ -d "$path" ]] && { echo "Exists: $path"; return 1; }

    [[ -z "$base" ]] && base=$(_wt_default_branch)

    if $existing; then
        git worktree add "$path" "$branch"
    else
        git worktree add "$path" -b "$branch" "$base"
    fi || return 1

    if [[ -n "$TMUX" ]]; then
        tmux new-window -n "$branch" -c "$path"
        echo "Opened tmux window: $branch"
    else
        echo "cd $path"
    fi
}

# List worktrees with dirty status
wt-list() {
    git worktree list --porcelain | while read -r line; do
        [[ "$line" == worktree* ]] && path="${line#worktree }"
        [[ "$line" == branch* ]] && branch="${line#branch refs/heads/}"
        if [[ -z "$line" && -n "$path" ]]; then
            local status="clean"
            [[ -n $(git -C "$path" status --porcelain 2>/dev/null) ]] && status="dirty"
            printf "%-30s %-20s [%s]\n" "$(basename "$path")" "$branch" "$status"
            path="" branch=""
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
