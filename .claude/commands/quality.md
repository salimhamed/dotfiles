# Run Quality Checks

Run tests, linting, and type checking for the current project.

## Usage

```
/user:quality [--fix] [--tests-only] [--lint-only] [--types-only]
```

## Arguments

- `--fix` - Auto-fix linting issues where possible
- `--tests-only` - Run only tests
- `--lint-only` - Run only linting
- `--types-only` - Run only type checking

## Process

1. **Detect project type** by checking for config files:
   - `pyproject.toml` or `setup.py` → Python project
   - `package.json` → Node/TypeScript project
   - Both → Mixed project (run checks for both)

2. **Run checks** based on project type:

### Python Projects

```bash
# Linting (prefer ruff, fallback to flake8)
ruff check . [--fix]
# or
flake8 .

# Type checking (prefer pyright, fallback to mypy)
pyright
# or
mypy .

# Tests
pytest -v
```

### TypeScript/JavaScript Projects

```bash
# Linting
npm run lint [-- --fix]
# or
npx eslint . [--fix]

# Type checking
npx tsc --noEmit

# Tests (detect runner from package.json)
npm test
# or
npx vitest run
# or
npx jest
```

3. **Aggregate results** and present summary:

```
## Quality Check Results

### Tests: PASSED (42 passed, 0 failed)
All tests passed in 3.2s

### Linting: 3 issues found
- src/utils.py:15 - Line too long (88 > 79)
- src/utils.py:23 - Unused import 'os'
- src/main.py:5 - Missing docstring

### Type Checking: PASSED
No type errors found

---
Summary: 3 issues to address
Run with --fix to auto-fix 2 of these issues
```

4. **Suggest fixes** for common issues

## Tool Detection

The command auto-detects available tools:

| Tool | Detection Method |
|------|------------------|
| ruff | `ruff --version` or pyproject.toml `[tool.ruff]` |
| pytest | pyproject.toml or pytest.ini |
| mypy | pyproject.toml `[tool.mypy]` or mypy.ini |
| pyright | pyrightconfig.json or pyproject.toml |
| eslint | .eslintrc.* or package.json eslintConfig |
| vitest | vitest.config.* or vite.config.* |
| jest | jest.config.* or package.json jest |

## Examples

### Run all checks
```
/user:quality
```

### Auto-fix linting issues
```
/user:quality --fix
```

### Run only tests
```
/user:quality --tests-only
```

## Exit Codes

Report success/failure based on:
- Tests: Any failing tests = failure
- Linting: Any errors (not warnings) = failure
- Types: Any type errors = failure

## Notes

- Respects project configuration (pyproject.toml, .eslintrc, etc.)
- Uses project's installed versions of tools when available
- Falls back to globally installed tools if needed
- Parallel execution where tools support it
