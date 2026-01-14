# Git worktree helpers

# --- Internal helpers ---

_wt_root() {
    local wt_git_dir=$(git rev-parse --git-common-dir 2>/dev/null) || return 1
    [[ "$wt_git_dir" == ".git" ]] && git rev-parse --show-toplevel || dirname "$wt_git_dir"
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
    local wt_name="$1" wt_root
    wt_root=$(_wt_root) || return 1
    echo "$(dirname "$wt_root")/$wt_name"
}

_wt_goto() {
    local wt_name="$1" wt_path
    wt_path=$(_wt_path "$wt_name") || return 1

    [[ -d "$wt_path" ]] || { echo "Not found: $wt_path"; return 1; }

    if [[ -n "$TMUX" ]]; then
        if tmux list-windows -F '#{window_name}' | grep -qx "$wt_name"; then
            tmux select-window -t "$wt_name"
        else
            tmux new-window -n "$wt_name" -c "$wt_path"
        fi
    else
        cd "$wt_path"
    fi
}

# --- Navigation ---

wt() {
    local wt_root wt_names wt_match
    wt_root=$(_wt_root) || { echo "Not in a git repo"; return 1; }
    wt_names=$(_wt_list_names)

    [[ -z "$wt_names" ]] && { echo "No worktrees found"; return 1; }

    if [[ -z "$1" ]]; then
        wt_match=$(echo "$wt_names" | fzf --height=40% --reverse) || return 1
    else
        local wt_filtered
        wt_filtered=$(echo "$wt_names" | grep -i "$1")

        if [[ -z "$wt_filtered" ]]; then
            echo "No worktree matching: $1"
            return 1
        elif [[ $(echo "$wt_filtered" | wc -l) -eq 1 ]]; then
            wt_match="$wt_filtered"
        else
            wt_match=$(echo "$wt_filtered" | fzf --height=40% --reverse --query="$1") || return 1
        fi
    fi

    _wt_goto "$wt_match"
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
        local wt_tracking=""
        [[ "$wt_ahead" -gt 0 ]] && wt_tracking="+$wt_ahead ahead"
        [[ "$wt_behind" -gt 0 ]] && wt_tracking="${wt_tracking:+$wt_tracking, }$wt_behind behind"
        [[ -n "$wt_tracking" ]] && echo "  Branch: $wt_branch ($wt_tracking)"
        [[ -z "$wt_tracking" ]] && echo "  Branch: $wt_branch (up to date)"
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
        local wt_pr_num wt_pr_title wt_pr_draft wt_pr_marker
        wt_pr_num=$(echo "$wt_pr" | grep -o '"number":[0-9]*' | cut -d: -f2)
        wt_pr_title=$(echo "$wt_pr" | grep -o '"title":"[^"]*"' | cut -d'"' -f4)
        wt_pr_draft=$(echo "$wt_pr" | grep -o '"isDraft":true')
        [[ -n "$wt_pr_draft" ]] && wt_pr_marker="[draft] "
        echo "  PR: #$wt_pr_num ${wt_pr_marker}- $wt_pr_title"
    fi
}

wt-status() {
    local wt_root wt_default_branch wt_pr_data
    wt_root=$(_wt_root) || { echo "Not in a git repo"; return 1; }
    wt_default_branch=$(_wt_default_branch)

    wt_pr_data=$(gh pr list --json number,headRefName,isDraft,reviewDecision --state open 2>/dev/null)

    printf "%-18s %-6s %-22s %s\n" "WORKTREE" "STATUS" "PR" "SYNC"

    local wt_path="" wt_branch=""
    git worktree list --porcelain | while read -r wt_line; do
        [[ "$wt_line" == worktree* ]] && wt_path="${wt_line#worktree }"
        [[ "$wt_line" == branch* ]] && wt_branch="${wt_line#branch refs/heads/}"

        if [[ -z "$wt_line" && -n "$wt_path" ]]; then
            local wt_name wt_status wt_pr_info wt_sync_info
            wt_name=$(basename "$wt_path")

            wt_status="clean"
            [[ -n $(git -C "$wt_path" status --porcelain 2>/dev/null) ]] && wt_status="dirty"

            if [[ "$wt_branch" == "$wt_default_branch" ]]; then
                wt_pr_info="-"
            else
                local wt_pr_num wt_pr_draft wt_pr_review wt_pr_state=""
                wt_pr_num=$(echo "$wt_pr_data" | jq -r --arg b "$wt_branch" '.[] | select(.headRefName==$b) | .number' 2>/dev/null)
                if [[ -n "$wt_pr_num" && "$wt_pr_num" != "null" ]]; then
                    wt_pr_draft=$(echo "$wt_pr_data" | jq -r --arg b "$wt_branch" '.[] | select(.headRefName==$b) | .isDraft')
                    wt_pr_review=$(echo "$wt_pr_data" | jq -r --arg b "$wt_branch" '.[] | select(.headRefName==$b) | .reviewDecision')
                    if [[ "$wt_pr_draft" == "true" ]]; then
                        wt_pr_state="draft"
                    elif [[ "$wt_pr_review" == "APPROVED" ]]; then
                        wt_pr_state="approved"
                    elif [[ "$wt_pr_review" == "CHANGES_REQUESTED" ]]; then
                        wt_pr_state="changes"
                    elif [[ -n "$wt_pr_review" && "$wt_pr_review" != "null" && "$wt_pr_review" != "" ]]; then
                        wt_pr_state="review"
                    else
                        wt_pr_state="open"
                    fi
                    wt_pr_info="#${wt_pr_num} ${wt_pr_state}"
                else
                    wt_pr_info="(none)"
                fi
            fi

            if [[ "$wt_branch" == "$wt_default_branch" ]]; then
                wt_sync_info="current"
            else
                local wt_counts wt_ahead wt_behind
                wt_counts=$(git -C "$wt_path" rev-list --left-right --count "${wt_default_branch}...${wt_branch}" 2>/dev/null)
                if [[ -n "$wt_counts" ]]; then
                    wt_behind=$(echo "$wt_counts" | cut -f1)
                    wt_ahead=$(echo "$wt_counts" | cut -f2)
                    if [[ "$wt_ahead" == "0" && "$wt_behind" == "0" ]]; then
                        wt_sync_info="current"
                    else
                        wt_sync_info="+${wt_ahead}/-${wt_behind}"
                    fi
                else
                    wt_sync_info="?"
                fi
            fi

            printf "%-18s %-6s %-22s %s\n" "$wt_name" "$wt_status" "$wt_pr_info" "$wt_sync_info"
            wt_path="" wt_branch=""
        fi
    done
}

wt-list() {
    local wt_path="" wt_branch="" wt_status=""
    git worktree list --porcelain | while read -r wt_line; do
        [[ "$wt_line" == worktree* ]] && wt_path="${wt_line#worktree }"
        [[ "$wt_line" == branch* ]] && wt_branch="${wt_line#branch refs/heads/}"
        if [[ -z "$wt_line" && -n "$wt_path" ]]; then
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
    local wt_default=$(_wt_default_branch)
    local wt_merged=$(git branch --merged "$wt_default" 2>/dev/null | grep -vE "^\*|^[[:space:]]*${wt_default}$")
    if [[ -n "$wt_merged" ]]; then
        echo "Merged branches:"
        echo "$wt_merged"
    else
        echo "No merged branches."
    fi
}
