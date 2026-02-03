---
name: pr
description: Create a pull request with title and body from branch context
disable-model-invocation: true
allowed-tools:
  - Bash(git *)
  - Bash(gh *)
  - Bash(python *)
---

# Create Pull Request

!read references/usage.md

## Gather Context

Run the gather script:

```bash
python scripts/gather_context.py
```

## Preconditions

Check these in the JSON output BEFORE proceeding:

1. **Not on base branch**: If `current_branch` equals `base_branch`, STOP and say:
   "Error: Cannot create PR from the base branch. Create a feature branch first."
2. **Has commits**: If `commits` array is empty, STOP and say:
   "Error: No commits found. Make commits before creating a PR."
3. **No existing PR**: If `existing_pr` is not null, STOP and say:
   "Error: PR already exists: <url>. Use /pr-title or /pr-desc to update it."

## Execution

Create the PR:

```bash
python scripts/create_pr.py --title "<title>" --body "<body>"
```

## Title Format

- Under 70 characters
- Imperative mood (e.g., "Add feature" not "Added feature")
- No period at end
- Summarize the main change

## Body Format

Use this exact structure:

```
## Summary

- <bullet 1: main change, start with verb>
- <bullet 2: supporting change or context>
- <optional bullet 3-4 if needed>
```

Rules:

- Each bullet starts with a verb (Add, Fix, Update, Remove, etc.)
- Focus on WHAT and WHY, not HOW
- No file paths unless the file itself is the feature

## Output

After creating the PR, output:

```
Created PR #<number>: <title>
<url>
```
