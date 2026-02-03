---
name: pr-desc
description: Update PR description from current branch context
disable-model-invocation: true
allowed-tools:
  - Bash(git *)
  - Bash(gh *)
  - Bash(python *)
---

# Update PR Description

!read references/usage.md

## Gather Context

Run the gather script:

```bash
python scripts/gather_context.py
```

## Preconditions

Check these in the JSON output BEFORE proceeding:

1. **PR must exist**: If `pr_number` is null, STOP and say:
   "Error: No PR exists for this branch. Use /pr to create one first."

## Execution

Update the PR body:

```bash
python scripts/update_description.py --body "<new body>"
```

## Body Format

Use this exact structure:

```
## Summary

- <bullet 1: main change, start with verb>
- <bullet 2: supporting change or context>
- <optional bullet 3-4 if needed>
```

Rules:

- 2-4 bullets only
- Each bullet starts with a verb (Add, Fix, Update, Remove, etc.)
- Focus on WHAT and WHY, not HOW
- No file paths unless the file itself is the feature
- No implementation details
- Derive content from commits and diff, not the old body

## Output

After updating, output:

```
Updated PR #<number> description
<url>
```
