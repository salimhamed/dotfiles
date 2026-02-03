---
name: pr-title
description: Update PR title from current branch context
disable-model-invocation: true
allowed-tools:
  - Bash(git *)
  - Bash(gh *)
  - Bash(python *)
---

# Update PR Title

!read references/usage.md

## Gather Context

Run the gather script:

```bash
python scripts/gather_context.py
```

## Preconditions

Check these in the JSON output BEFORE proceeding:

1. **PR must exist**: If `pr_number` is null, STOP and say: "Error: No PR exists
   for this branch. Use /pr to create one first."

## Execution

Update the PR title:

```bash
python scripts/update_title.py --title "<new title>"
```

## Title Format

- Under 70 characters
- Imperative mood (e.g., "Add feature" not "Added feature")
- No period at end
- Summarize the main change from commits and diff

## Output

After updating, output:

```
Updated PR #<number> title to: <new title>
<url>
```
