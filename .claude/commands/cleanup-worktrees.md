# Cleanup Worktrees

Remove worktrees for branches that have been merged.

## Usage

```
/user:cleanup-worktrees
```

## Process

1. **List current worktrees:**
   ```bash
   worktree-list
   ```

2. **Run cleanup script:**
   ```bash
   worktree-cleanup
   ```

3. **Report results:**
   - Which worktrees were removed
   - Which branches were deleted
   - Any errors encountered

## Notes

- Only removes worktrees for branches merged into the default branch (main/master)
- Requires confirmation before deletion
- Will not remove worktrees with uncommitted changes without force
