---
name: pr
description: Create a pull request with title and body from branch context
---

# Create Pull Request

Create a PR using `gh` CLI with title and body derived from the feature branch.

## Steps

1. **Analyze the branch**:
   ```bash
   git log main..HEAD --oneline
   git diff main...HEAD --stat
   ```

2. **Generate title**: Short summary (under 70 chars) from commits/changes

3. **Generate body**: Use this format:
   ```markdown
   ## Description
   <bullet points of what changed>
   ```

4. **Create PR**:
   ```bash
   gh pr create --title "..." --body "..."
   ```

5. **Return the PR URL**

## Notes

- Base branch: `main`
- Push branch first if needed: `git push -u origin HEAD`
- Run `/fix` and `/test` before creating PR
