# PR Title Scripts Usage

## gather_context.py

Collects all context needed for updating a PR title.

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
  "current_title": "Old title",
  "commits": ["abc1234 Add feature", "def5678 Fix bug"],
  "diff_stat": "+150 -30 in 5 files",
  "files_changed": ["src/foo.py", "src/bar.py"],
  "diff": "truncated diff content (~500 lines max)"
}
```

### Fields

| Field          | Type         | Description                         |
| -------------- | ------------ | ----------------------------------- |
| current_branch | string       | Current git branch name             |
| base_branch    | string       | Default branch from GitHub          |
| pr_number      | int\|null    | PR number if exists                 |
| pr_url         | string\|null | PR URL if exists                    |
| current_title  | string\|null | Current PR title                    |
| commits        | string[]     | Commit summaries (hash + message)   |
| diff_stat      | string       | Git diff stat (last 20 lines)       |
| files_changed  | string[]     | List of changed file paths (max 30) |
| diff           | string       | Full diff, truncated at ~500 lines  |

---

## update_title.py

Updates the PR title using the GitHub CLI.

### Usage

```bash
python scripts/update_title.py --title "New title here"
```

### Arguments

| Argument | Required | Description                                    |
| -------- | -------- | ---------------------------------------------- |
| --title  | Yes      | New PR title (under 70 chars, imperative mood) |

### Behavior

- Runs `gh pr edit --title` on current branch's PR
- Exit code matches `gh pr edit` exit code

### Error Scenarios

- No PR exists: Use `/pr` to create one first
- Not authenticated: `gh auth login` required
