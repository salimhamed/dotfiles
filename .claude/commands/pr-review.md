# Review Pull Request

Perform a thorough code review of a pull request.

## Usage

```
/user:pr-review <pr-number>
```

## Process

1. **Fetch PR details:**
   ```bash
   gh pr view <pr-number> --json title,body,files,commits,additions,deletions
   gh pr diff <pr-number>
   ```

2. **Review checklist:**
   - [ ] Code follows project standards
   - [ ] Changes match PR description
   - [ ] Tests added/updated appropriately
   - [ ] No security vulnerabilities introduced
   - [ ] No performance regressions
   - [ ] Documentation updated if needed

3. **Analyze changes:**
   - Review each modified file
   - Verify logic correctness
   - Look for edge cases
   - Check error handling

4. **Provide feedback** in this format:

```markdown
## PR Review: #<number> - <title>

### Summary
<brief overview of changes>

### Issues Found
- **file.py:42** - <issue description>
- **component.tsx:18** - <issue description>

### Suggestions
- Consider <improvement>

### What's Good
- <positive observations>

### Verdict
<APPROVE | REQUEST_CHANGES | COMMENT>

<reasoning for verdict>
```
