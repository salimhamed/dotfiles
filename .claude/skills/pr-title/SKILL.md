---
name: pr-title
description: Update PR title from current branch context
---

# Update PR Title

Update the current PR's title based on branch changes.

## Steps

1. **Get current PR**: `gh pr view --json number,title`
2. **Analyze changes**: `git log main..HEAD --oneline` and `git diff main...HEAD --stat`
3. **Generate new title**: Short summary (under 70 chars)
4. **Update**: `gh pr edit --title "..."`
