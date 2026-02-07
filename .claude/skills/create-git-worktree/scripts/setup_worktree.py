#!/usr/bin/env python3
import json
import subprocess
import sys
from pathlib import Path


def run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, capture_output=True, text=True, **kwargs)


def output(status: str, **fields):
    print(json.dumps({"status": status, **fields}))
    sys.exit(0 if status == "success" else 1)


def get_default_branch() -> str:
    result = run(["git", "symbolic-ref", "refs/remotes/origin/HEAD"])
    if result.returncode == 0:
        return result.stdout.strip().removeprefix("refs/remotes/origin/")

    result = run(["git", "remote", "show", "origin"])
    if result.returncode != 0:
        output("error", message="Cannot determine default branch: no remote 'origin' found.")
    for line in result.stdout.splitlines():
        if "HEAD branch:" in line:
            return line.split(":")[-1].strip()

    output("error", message="Cannot determine default branch from 'git remote show origin'.")


def main():
    if len(sys.argv) < 2 or not sys.argv[1].strip():
        output("error", message="Usage: setup_worktree.py <branch-name> [--parent-dir <path>]")

    branch_name = sys.argv[1].strip()

    # Must be inside a git repo
    result = run(["git", "rev-parse", "--show-toplevel"])
    if result.returncode != 0:
        output("error", message="Not inside a git repository.")
    repo_root = Path(result.stdout.strip())

    # Detect default branch
    default_branch = get_default_branch()

    # Verify on default branch
    result = run(["git", "branch", "--show-current"])
    current_branch = result.stdout.strip()
    if current_branch != default_branch:
        output("wrong_branch", current_branch=current_branch, default_branch=default_branch)

    # Fetch and check freshness
    result = run(["git", "fetch", "origin", default_branch, "--quiet"])
    if result.returncode != 0:
        output("error", message=f"Failed to fetch origin/{default_branch}. Check your network connection.")

    local_sha = run(["git", "rev-parse", default_branch]).stdout.strip()
    remote_sha = run(["git", "rev-parse", f"origin/{default_branch}"]).stdout.strip()
    if local_sha != remote_sha:
        output("behind_origin", default_branch=default_branch)

    # Compute worktree path
    parent_dir = repo_root.parent
    for i, arg in enumerate(sys.argv[2:], start=2):
        if arg == "--parent-dir" and i + 1 < len(sys.argv):
            parent_dir = Path(sys.argv[i + 1])
            break
    sanitized = branch_name.replace("/", "-")
    worktree_path = parent_dir / sanitized

    if worktree_path.exists():
        output("error", message=f"Path already exists: {worktree_path}")

    # Create worktree
    result = run(["git", "worktree", "add", str(worktree_path), "-b", branch_name])
    if result.returncode != 0:
        stderr = result.stderr.strip()
        output("error", message=f"git worktree add failed: {stderr}")

    output(
        "success",
        worktree_path=str(worktree_path),
        branch=branch_name,
        default_branch=default_branch,
        base_sha=local_sha,
    )


if __name__ == "__main__":
    main()
