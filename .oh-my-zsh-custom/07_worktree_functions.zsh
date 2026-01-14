# Git worktree helpers

# --- Internal helpers ---

_wt_root() {
    local d=$(git rev-parse --git-common-dir 2>/dev/null) || return 1
    [[ "$d" == ".git" ]] && git rev-parse --show-toplevel || dirname "$d"
}

_wt_default_branch() {
    command git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | command sed 's@^refs/remotes/origin/@@' || echo main
}

_wt_list_names() {
    git worktree list --porcelain 2>/dev/null | \
        awk '/^worktree / { print $2 }' | \
        xargs -n1 basename
}

_wt_path() {
    local name="$1" root
    root=$(_wt_root) || return 1
    echo "$(dirname "$root")/$name"
}

_wt_goto() {
    local name="$1" path
    path=$(_wt_path "$name") || return 1

    [[ -d "$path" ]] || { echo "Not found: $path"; return 1; }

    if [[ -n "$TMUX" ]]; then
        if tmux list-windows -F '#{window_name}' | grep -qx "$name"; then
            tmux select-window -t "$name"
        else
            tmux new-window -n "$name" -c "$path"
        fi
    else
        cd "$path"
    fi
}

# --- Navigation ---

wt() {
    local root names match
    root=$(_wt_root) || { echo "Not in a git repo"; return 1; }
    names=$(_wt_list_names)

    [[ -z "$names" ]] && { echo "No worktrees found"; return 1; }

    if [[ -z "$1" ]]; then
        match=$(echo "$names" | fzf --height=40% --reverse) || return 1
    else
        local filtered
        filtered=$(echo "$names" | grep -i "$1")

        if [[ -z "$filtered" ]]; then
            echo "No worktree matching: $1"
            return 1
        elif [[ $(echo "$filtered" | wc -l) -eq 1 ]]; then
            match="$filtered"
        else
            match=$(echo "$filtered" | fzf --height=40% --reverse --query="$1") || return 1
        fi
    fi

    _wt_goto "$match"
}

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

# --- Status & Info ---

wt-here() {
    local wt_branch wt_path wt_upstream wt_ahead wt_behind wt_modified wt_staged wt_pr

    wt_branch=$(git branch --show-current 2>/dev/null) || {
        echo "Not in a git repo"
        return 1
    }
    [[ -z "$wt_branch" ]] && {
        echo "Detached HEAD"
        return 1
    }

    wt_path=$(git rev-parse --show-toplevel)
    echo "$wt_branch @ $wt_path"

    wt_upstream=$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
    if [[ -n "$wt_upstream" ]]; then
        wt_ahead=$(git rev-list --count '@{upstream}..HEAD' 2>/dev/null)
        wt_behind=$(git rev-list --count 'HEAD..@{upstream}' 2>/dev/null)
        local tracking=""
        [[ "$wt_ahead" -gt 0 ]] && tracking="+$wt_ahead ahead"
        [[ "$wt_behind" -gt 0 ]] && tracking="${tracking:+$tracking, }$wt_behind behind"
        [[ -n "$tracking" ]] && echo "  Branch: $wt_branch ($tracking)"
        [[ -z "$tracking" ]] && echo "  Branch: $wt_branch (up to date)"
    else
        echo "  Branch: $wt_branch (no upstream)"
    fi

    wt_modified=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
    wt_staged=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$wt_modified" -gt 0 || "$wt_staged" -gt 0 ]]; then
        echo "  Status: ${wt_modified} modified, ${wt_staged} staged"
    else
        echo "  Status: clean"
    fi

    wt_pr=$(timeout 1 gh pr view --json number,title,isDraft 2>/dev/null)
    if [[ -n "$wt_pr" ]]; then
        local pr_num pr_title pr_draft pr_marker
        pr_num=$(echo "$wt_pr" | grep -o '"number":[0-9]*' | cut -d: -f2)
        pr_title=$(echo "$wt_pr" | grep -o '"title":"[^"]*"' | cut -d'"' -f4)
        pr_draft=$(echo "$wt_pr" | grep -o '"isDraft":true')
        [[ -n "$pr_draft" ]] && pr_marker="[draft] "
        echo "  PR: #$pr_num ${pr_marker}- $pr_title"
    fi
}

wt-status() {
    local wt_root default_branch pr_data
    wt_root=$(_wt_root) || { echo "Not in a git repo"; return 1; }
    default_branch=$(_wt_default_branch)

    pr_data=$(gh pr list --json number,headRefName,isDraft,reviewDecision --state open 2>/dev/null)

    printf "%-18s %-6s %-22s %s\n" "WORKTREE" "STATUS" "PR" "SYNC"

    local wt_path="" wt_branch=""
    git worktree list --porcelain | while read -r line; do
        [[ "$line" == worktree* ]] && wt_path="${line#worktree }"
        [[ "$line" == branch* ]] && wt_branch="${line#branch refs/heads/}"

        if [[ -z "$line" && -n "$wt_path" ]]; then
            local name status pr_info sync_info
            name=$(basename "$wt_path")

            status="clean"
            [[ -n $(git -C "$wt_path" status --porcelain 2>/dev/null) ]] && status="dirty"

            if [[ "$wt_branch" == "$default_branch" ]]; then
                pr_info="-"
            else
                local pr_num pr_draft pr_review pr_state=""
                pr_num=$(echo "$pr_data" | jq -r --arg b "$wt_branch" '.[] | select(.headRefName==$b) | .number' 2>/dev/null)
                if [[ -n "$pr_num" && "$pr_num" != "null" ]]; then
                    pr_draft=$(echo "$pr_data" | jq -r --arg b "$wt_branch" '.[] | select(.headRefName==$b) | .isDraft')
                    pr_review=$(echo "$pr_data" | jq -r --arg b "$wt_branch" '.[] | select(.headRefName==$b) | .reviewDecision')
                    if [[ "$pr_draft" == "true" ]]; then
                        pr_state="draft"
                    elif [[ "$pr_review" == "APPROVED" ]]; then
                        pr_state="approved"
                    elif [[ "$pr_review" == "CHANGES_REQUESTED" ]]; then
                        pr_state="changes"
                    elif [[ -n "$pr_review" && "$pr_review" != "null" && "$pr_review" != "" ]]; then
                        pr_state="review"
                    else
                        pr_state="open"
                    fi
                    pr_info="#${pr_num} ${pr_state}"
                else
                    pr_info="(none)"
                fi
            fi

            if [[ "$wt_branch" == "$default_branch" ]]; then
                sync_info="current"
            else
                local counts ahead behind
                counts=$(git -C "$wt_path" rev-list --left-right --count "${default_branch}...${wt_branch}" 2>/dev/null)
                if [[ -n "$counts" ]]; then
                    behind=$(echo "$counts" | cut -f1)
                    ahead=$(echo "$counts" | cut -f2)
                    if [[ "$ahead" == "0" && "$behind" == "0" ]]; then
                        sync_info="current"
                    else
                        sync_info="+${ahead}/-${behind}"
                    fi
                else
                    sync_info="?"
                fi
            fi

            printf "%-18s %-6s %-22s %s\n" "$name" "$status" "$pr_info" "$sync_info"
            wt_path="" wt_branch=""
        fi
    done
}

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

# --- Cleanup ---

wt-done() {
    local wt_branch="${1:-$(git branch --show-current)}"

    [[ -z "$wt_branch" ]] && {
        echo "Not on a branch and no branch specified"
        return 1
    }

    local wt_default=$(_wt_default_branch)
    [[ "$wt_branch" == "$wt_default" ]] && {
        echo "Cannot clean up default branch: $wt_default"
        return 1
    }

    local wt_repo
    wt_repo=$(_wt_root) || {
        echo "Not in a git repo"
        return 1
    }

    local wt_pr_state
    wt_pr_state=$(gh pr view "$wt_branch" --json state --jq '.state' 2>/dev/null) || {
        echo "No PR found for branch: $wt_branch"
        return 1
    }

    [[ "$wt_pr_state" != "MERGED" ]] && {
        echo "PR not merged (state: $wt_pr_state). Aborting."
        return 1
    }

    echo "PR merged. Cleaning up $wt_branch..."

    [[ -n "$TMUX" ]] && tmux kill-window -t "$wt_branch" 2>/dev/null && \
        echo "Closed tmux window: $wt_branch"

    cd "$wt_repo" || {
        echo "Failed to switch to main worktree"
        return 1
    }

    local wt_path="$(dirname "$wt_repo")/$wt_branch"
    if [[ -d "$wt_path" ]]; then
        git worktree remove "$wt_path" --force && echo "Removed worktree: $wt_path"
    fi

    git branch -D "$wt_branch" 2>/dev/null && echo "Deleted local branch: $wt_branch"

    if git ls-remote --exit-code --heads origin "$wt_branch" &>/dev/null; then
        printf "Delete remote branch origin/%s? [y/N] " "$wt_branch"
        read -r wt_reply
        [[ "$wt_reply" =~ ^[Yy]$ ]] && {
            git push origin --delete "$wt_branch" && echo "Deleted remote branch: origin/$wt_branch"
        }
    fi

    echo "Done."
}

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
