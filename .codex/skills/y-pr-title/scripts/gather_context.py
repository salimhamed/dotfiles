#!/usr/bin/env python3
"""Gather context for generating a yadm PR title."""

import json
import subprocess


def run(cmd: list[str]) -> str:
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout.strip()


def get_current_branch() -> str:
    return run(["yadm", "branch", "--show-current"])


def get_commits(base_branch: str) -> list[str]:
    output = run(["yadm", "log", f"{base_branch}..HEAD", "--oneline"])
    return output.splitlines() if output else []


def get_diff_stat(base_branch: str) -> str:
    output = run(["yadm", "diff", f"{base_branch}...HEAD", "--stat"])
    lines = output.splitlines()
    return "\n".join(lines[-20:]) if len(lines) > 20 else output


def get_files_changed(base_branch: str) -> list[str]:
    output = run(["yadm", "diff", f"{base_branch}...HEAD", "--name-only"])
    return output.splitlines() if output else []


def main():
    base_branch = "main"
    current_branch = get_current_branch()

    context = {
        "current_branch": current_branch,
        "base_branch": base_branch,
        "commits": get_commits(base_branch),
        "diff_stat": get_diff_stat(base_branch),
        "files_changed": get_files_changed(base_branch),
    }

    print(json.dumps(context, indent=2))


if __name__ == "__main__":
    main()
