# Fix GitHub Issue

Analyze and fix a GitHub issue with proper workflow.

## Usage

```
/user:fix-issue <issue-number>
```

## Process

1. **Fetch issue details:**
   ```bash
   gh issue view <issue-number> --json title,body,labels,comments
   ```

2. **Analyze the issue:**
   - Understand the problem described
   - Identify affected areas of codebase
   - Check for related issues or PRs

3. **Search codebase:**
   - Find relevant files using grep/ripgrep
   - Understand current implementation
   - Identify test files

4. **Plan the fix:**
   - For simple bugs: proceed with implementation
   - For complex changes: present plan and wait for approval

5. **Implement:**
   - Make minimal, focused changes
   - Follow project coding standards (check CLAUDE.md)
   - Add or update tests

6. **Verify:**
   - Run the project's test suite
   - Run linters if configured
   - Check types if applicable

7. **Create commit:**
   - Use conventional commit format
   - Reference issue number: `fix: resolve login timeout (#123)`

8. **Create PR:**
   ```bash
   gh pr create --title "Fix: <issue-title>" --body "Fixes #<issue-number>"
   ```

## Examples

### Simple bug fix
```
/user:fix-issue 1234
```

### Complex issue
```
/user:fix-issue 5678
```
For complex issues, I'll first present my analysis and proposed approach before implementing.
