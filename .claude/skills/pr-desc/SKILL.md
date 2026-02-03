---
name: pr-desc
description: Update PR description from current branch context
---

# Update PR Description

Update the current PR's body based on branch changes.

## Steps

1. **Get current PR**: `gh pr view --json number,body`
2. **Analyze changes**: `git log main..HEAD --oneline` and `git diff main...HEAD`
3. **Generate new body**:
   ```markdown
   ## Description
   <2-3 bullet points of what changed>
   ```
4. **Update**: `gh pr edit --body "..."`
