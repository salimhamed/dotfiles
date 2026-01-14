## Python

- Only add docstrings for complex/nuanced code. Code should read like a book.

## Zsh

### Variable Naming Conventions

Use a function-specific prefix for all local variables to avoid conflicts with shell builtins, environment variables, and other functions.

**Avoid these generic variable names:**
- `path` - conflicts with `$PATH`
- `name` - common collision
- `status` - conflicts with `$?` semantics
- `line`, `count`, `match`, `result`, `output`
- `default`, `root`, `dir`, `file`
- Single-letter variables: `d`, `f`, `n`, `i`

**Pattern:** `<prefix>_<descriptive_name>`

Example for worktree functions using `wt_` prefix:
```zsh
wt_example() {
    local wt_branch wt_path wt_status
    wt_branch=$(git branch --show-current)
    wt_path=$(git rev-parse --show-toplevel)
    # ...
}
```

Reference: `~/.oh-my-zsh-custom/07_worktree_functions.zsh`

## Context Efficiency (Advanced Tool Use)

- Request summaries instead of raw data when possible
- Use batch operations for multiple items
- Process data in code, return only final results
- For large datasets, compute aggregates rather than returning all records
