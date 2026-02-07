#!/usr/bin/env python3
import shutil
import subprocess
import sys
from pathlib import Path


def get_main_worktree() -> Path:
    result = subprocess.run(
        ["git", "worktree", "list", "--porcelain"],
        capture_output=True,
        text=True,
        check=True,
    )
    first_line = result.stdout.splitlines()[0]
    return Path(first_line.removeprefix("worktree "))


def parse_worktreerc(main_root: Path) -> list[str]:
    rc = main_root / ".worktreerc"
    if not rc.exists():
        return []
    patterns = []
    for line in rc.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        patterns.append(line)
    return patterns


def sync_files(main_root: Path, target: Path, patterns: list[str]):
    for pattern in patterns:
        for source in main_root.glob(pattern):
            relative = source.relative_to(main_root)
            if relative == Path(".worktreerc"):
                continue
            dest = target / relative
            if dest.exists():
                continue
            dest.parent.mkdir(parents=True, exist_ok=True)
            if source.is_dir():
                shutil.copytree(source, dest)
            else:
                shutil.copy2(source, dest)
            print(f"  copied {relative}")


def main():
    try:
        main_root = get_main_worktree()
    except (subprocess.CalledProcessError, IndexError):
        print("Error: Could not determine main worktree. Are you in a git repository?")
        sys.exit(1)

    target = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.cwd()

    if main_root.resolve() == target.resolve():
        print("Already in main worktree, nothing to sync.")
        return

    patterns = parse_worktreerc(main_root)
    if not patterns:
        print("No .worktreerc found or no patterns defined.")
        return

    print(f"Syncing from {main_root} into {target}:")
    sync_files(main_root, target, patterns)
    print("Done.")


if __name__ == "__main__":
    main()
