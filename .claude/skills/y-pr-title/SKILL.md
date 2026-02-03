---
name: y-pr-title
description: Generate PR title for yadm branch
allowed-tools:
  - Bash(yadm *)
  - Bash(python *)
---

# Generate PR Title for Yadm Branch

## Gather Context

Run the gather script:

```bash
python scripts/gather_context.py
```

## Title Format

- Under 70 characters
- Imperative mood (e.g., "Add feature" not "Added feature")
- No period at end
- Summarize the main change

## Output

Output in this exact format for copy/paste:

```
---
**Title:**
<title here>
---
```
