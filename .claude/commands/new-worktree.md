# Create New Worktree

Create a new git worktree for parallel development.

## Usage

```
/user:new-worktree <branch-name> [options]
```

## Options

- `--from <branch>` - Base branch (default: main/master)
- `--existing` - Use existing branch
- `--no-setup` - Skip environment setup
- `--claude` - Start Claude Code in new tmux window

## Process

Run the worktree creation script:

```bash
worktree-new $ARGUMENTS
```

Report the result with the new worktree path and next steps.

## Examples

### Basic feature branch
```
/user:new-worktree feature-user-auth
```

### From existing branch with Claude
```
/user:new-worktree bugfix-jwt --existing --claude
```

### From develop branch
```
/user:new-worktree feature-api --from develop
```
