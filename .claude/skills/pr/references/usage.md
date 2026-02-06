# PR Scripts Usage

## gather_context.py

Collects all context needed for creating a pull request.

### Usage

```bash
python ~/.claude/skills/pr/scripts/gather_context.py
```

### Output Schema

```json
{
  "current_branch": "feature-x",
  "base_branch": "main",
  "is_pushed": true,
  "existing_pr": null,
  "commits": ["abc1234 Add feature", "def5678 Fix bug"],
  "diff_stat": "+150 -30 in 5 files",
  "files_changed": ["src/foo.py", "src/bar.py"],
  "diff": "truncated diff content (~500 lines max)"
}
```

### Fields

| Field          | Type         | Description                             |
| -------------- | ------------ | --------------------------------------- |
| current_branch | string       | Current git branch name                 |
| base_branch    | string       | Default branch from GitHub              |
| is_pushed      | boolean      | Whether branch has remote tracking      |
| existing_pr    | object\|null | PR number/url if exists, null otherwise |
| commits        | string[]     | Commit summaries (hash + message)       |
| diff_stat      | string       | Git diff stat (last 20 lines)           |
| files_changed  | string[]     | List of changed file paths              |
| diff           | string       | Full diff, truncated at ~500 lines      |

---

## create_pr.py

Creates a pull request using the GitHub CLI.

### Usage

```bash
python ~/.claude/skills/pr/scripts/create_pr.py --title "Add feature X" --body "## Summary\n- Add ..."
```

### Arguments

| Argument | Required | Description                                |
| -------- | -------- | ------------------------------------------ |
| --title  | Yes      | PR title (under 70 chars, imperative mood) |
| --body   | Yes      | PR body (markdown format)                  |

### Behavior

- Runs `gh pr create` with provided title and body
- `gh` handles pushing if branch isn't pushed
- Exit code matches `gh pr create` exit code

### Error Scenarios

- Not authenticated: `gh auth login` required
- No commits: Create commits first
- PR exists: Use `/pr-title` or `/pr-desc` instead
