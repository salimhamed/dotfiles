# PR Description Scripts Usage

## gather_context.py

Collects all context needed for updating a PR description.

### Usage

```bash
python scripts/gather_context.py
```

### Output Schema

```json
{
  "current_branch": "feature-x",
  "base_branch": "main",
  "pr_number": 123,
  "pr_url": "https://github.com/.../pull/123",
  "current_body": "existing description...",
  "commits": ["abc1234 Add feature", "def5678 Fix bug"],
  "diff_stat": "+150 -30 in 5 files",
  "files_changed": ["src/foo.py", "src/bar.py"],
  "diff": "truncated diff content (~500 lines max)"
}
```

### Fields

| Field | Type | Description |
|-------|------|-------------|
| current_branch | string | Current git branch name |
| base_branch | string | Default branch from GitHub |
| pr_number | int\|null | PR number if exists |
| pr_url | string\|null | PR URL if exists |
| current_body | string\|null | Current PR description |
| commits | string[] | Commit summaries (hash + message) |
| diff_stat | string | Git diff stat (last 20 lines) |
| files_changed | string[] | List of changed file paths (max 30) |
| diff | string | Full diff, truncated at ~500 lines |

---

## update_description.py

Updates the PR description using the GitHub CLI.

### Usage

```bash
python scripts/update_description.py --body "## Summary\n- Update feature X"
```

### Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| --body | Yes | New PR body (markdown format) |

### Behavior

- Runs `gh pr edit --body` on current branch's PR
- Exit code matches `gh pr edit` exit code

### Error Scenarios

- No PR exists: Use `/pr` to create one first
- Not authenticated: `gh auth login` required
