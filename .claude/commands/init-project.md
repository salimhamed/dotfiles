# Initialize Project for Claude Code

Set up a project with Claude Code best practices.

## Usage

```
/user:init-project
```

## Process

1. **Check for existing files:**
   - CLAUDE.md
   - .worktreeinclude
   - .claude/ directory

2. **Create .worktreeinclude** if it doesn't exist:
   ```
   # Python
   .venv
   .python-version

   # Node
   node_modules

   # IDE
   .idea
   .vscode

   # Environment
   .env
   .env.local
   .env.development
   ```

3. **Create CLAUDE.md** if it doesn't exist:
   - Detect project type (Python, Node, both)
   - Add appropriate commands section
   - Add coding standards
   - Reference global skills

4. **Create .claude/settings.local.json** for any project-specific overrides

5. **Report what was created** and suggest next steps

## What Gets Created

- `CLAUDE.md` - Project memory with detected tech stack
- `.worktreeinclude` - Files to copy to worktrees
- `.gitignore` additions if needed
