---
name: y-pr
description: Generate PR title and description for yadm branch
allowed-tools:
  - Bash(yadm *)
  - Bash(python *)
---

# Generate PR for Yadm Branch

## Gather Context

Run the gather script:

```bash
python scripts/gather_context.py
```

## Preconditions

Check these in the JSON output BEFORE proceeding:

1. **Not on main branch**: If `current_branch` equals "main", STOP and say:
   "Error: Cannot create PR from main. Create a feature branch first."
2. **Has commits**: If `commits` array is empty, STOP and say: "Error: No
   commits found. Make commits before creating a PR."

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

Output in this exact format for copy/paste:

```
---
**Title:**
<title here>

**Description:**
<body here>
---
```
