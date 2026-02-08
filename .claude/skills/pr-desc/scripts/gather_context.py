#!/usr/bin/env python3
"""Gather context for updating a PR description."""

import json
import subprocess


def run(cmd: list[str], check: bool = False) -> str:
    result = subprocess.run(cmd, capture_output=True, text=True)
    if check and result.returncode != 0:
        raise subprocess.CalledProcessError(result.returncode, cmd, result.stderr)
    return result.stdout.strip()


def get_base_branch() -> str:
    return run(["gh", "repo", "view", "--json", "defaultBranchRef", "-q", ".defaultBranchRef.name"]) or "main"


def get_current_branch() -> str:
    return run(["git", "branch", "--show-current"])


def get_current_pr() -> dict | None:
    output = run(["gh", "pr", "view", "--json", "number,url,body"])
    if not output:
        return None
    return json.loads(output)


def get_commits(base_branch: str) -> list[str]:
    output = run(["git", "log", f"{base_branch}..HEAD", "--oneline"])
    return output.splitlines() if output else []


def get_diff_stat(base_branch: str) -> str:
    output = run(["git", "diff", f"{base_branch}...HEAD", "--stat"])
    lines = output.splitlines()
    return "\n".join(lines[-20:]) if len(lines) > 20 else output


def get_files_changed(base_branch: str) -> list[str]:
    output = run(["git", "diff", f"{base_branch}...HEAD", "--name-only"])
    lines = output.splitlines()
    return lines[:30] if len(lines) > 30 else lines


def get_diff(base_branch: str, max_lines: int = 500) -> str:
    output = run(["git", "diff", f"{base_branch}...HEAD"])
    lines = output.splitlines()
    if len(lines) > max_lines:
        return "\n".join(lines[:max_lines]) + f"\n\n... (truncated, {len(lines) - max_lines} more lines)"
    return output


def main():
    base_branch = get_base_branch()
    current_branch = get_current_branch()
    pr = get_current_pr()

    context = {
        "current_branch": current_branch,
        "base_branch": base_branch,
        "pr_number": pr["number"] if pr else None,
        "pr_url": pr["url"] if pr else None,
        "current_body": pr["body"] if pr else None,
        "commits": get_commits(base_branch),
        "diff_stat": get_diff_stat(base_branch),
        "files_changed": get_files_changed(base_branch),
        "diff": get_diff(base_branch),
    }

    print(json.dumps(context, indent=2))


if __name__ == "__main__":
    main()
