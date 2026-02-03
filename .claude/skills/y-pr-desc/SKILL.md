---
name: y-pr-desc
description: Generate PR description for yadm branch
allowed-tools:
  - Bash(yadm *)
  - Bash(python *)
---

# Generate PR Description for Yadm Branch

## Gather Context

Run the gather script:

```bash
python scripts/gather_context.py
```

## Description Format

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
**Description:**
<body here>
---
```
