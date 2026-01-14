# Generate Commit

Analyze staged changes and generate a conventional commit message.

## Usage

```
/user:commit [--amend]
```

## Arguments

- `--amend` - Amend the previous commit instead of creating a new one

## Process

1. **Check for staged changes:**
   ```bash
   git diff --cached --stat
   ```
   If nothing is staged, inform the user and suggest staging files.

2. **Analyze the diff:**
   ```bash
   git diff --cached
   ```

3. **Determine commit type** based on changes:
   - `feat` - New feature or capability
   - `fix` - Bug fix
   - `refactor` - Code restructuring without behavior change
   - `docs` - Documentation only
   - `test` - Adding or updating tests
   - `chore` - Build, config, or tooling changes
   - `style` - Formatting, whitespace (no logic change)
   - `perf` - Performance improvement

4. **Generate commit message:**
   - Follow conventional commits format: `type(scope): description`
   - Scope is optional, derived from primary file/directory
   - Description should be imperative mood, lowercase, no period
   - Keep under 72 characters

5. **Present to user:**
   ```
   Staged files:
   - src/components/Button.tsx (modified)
   - src/components/Button.test.tsx (new)

   Proposed commit message:
   feat(components): add Button component with tests

   Options:
   1. Commit with this message
   2. Edit message
   3. Cancel
   ```

6. **Execute commit** (only after user confirms):
   ```bash
   git commit -m "<message>"
   ```
   Or with `--amend`:
   ```bash
   git commit --amend -m "<message>"
   ```

## Commit Message Guidelines

- **feat**: A new feature for the user
- **fix**: A bug fix for the user
- **docs**: Documentation changes only
- **style**: Formatting, missing semicolons, etc (no code change)
- **refactor**: Refactoring production code
- **test**: Adding tests, refactoring tests (no production code change)
- **chore**: Updating build tasks, package manager configs, etc

## Examples

### Basic usage
```
/user:commit
```
Analyzes staged changes and proposes a commit message.

### Amend previous commit
```
/user:commit --amend
```
Updates the previous commit with currently staged changes.

## Safety

- Never commit without user confirmation
- Show full diff summary before committing
- Warn if committing sensitive files (.env, credentials, etc.)
- Check for large binary files
