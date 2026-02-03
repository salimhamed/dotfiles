#!/usr/bin/env python3
"""Create a pull request with the given title and body."""

import argparse
import subprocess
import sys


def is_pushed() -> bool:
    result = subprocess.run(
        ["git", "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"],
        capture_output=True,
    )
    return result.returncode == 0


def push_branch() -> bool:
    branch = subprocess.run(
        ["git", "branch", "--show-current"],
        capture_output=True,
        text=True,
    ).stdout.strip()
    result = subprocess.run(["git", "push", "-u", "origin", branch])
    return result.returncode == 0


def main():
    parser = argparse.ArgumentParser(description="Create a pull request")
    parser.add_argument("--title", required=True, help="PR title")
    parser.add_argument("--body", required=True, help="PR body")
    args = parser.parse_args()

    if not is_pushed() and not push_branch():
        sys.exit(1)

    result = subprocess.run(
        ["gh", "pr", "create", "--title", args.title, "--body", args.body],
    )
    sys.exit(result.returncode)


if __name__ == "__main__":
    main()
