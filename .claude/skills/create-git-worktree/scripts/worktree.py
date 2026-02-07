#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "click>=8.1",
#     "pyyaml>=6.0",
# ]
# ///
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

import click
import yaml


def run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, capture_output=True, text=True, **kwargs)


def json_output(status: str, **fields):
    print(json.dumps({"status": status, **fields}))
    sys.exit(0 if status == "success" else 1)


def get_default_branch() -> str:
    result = run(["git", "symbolic-ref", "refs/remotes/origin/HEAD"])
    if result.returncode == 0:
        return result.stdout.strip().removeprefix("refs/remotes/origin/")

    result = run(["git", "remote", "show", "origin"])
    if result.returncode != 0:
        json_output("error", message="Cannot determine default branch: no remote 'origin' found.")
    for line in result.stdout.splitlines():
        if "HEAD branch:" in line:
            return line.split(":")[-1].strip()

    json_output("error", message="Cannot determine default branch from 'git remote show origin'.")


def get_main_worktree() -> Path:
    result = subprocess.run(
        ["git", "worktree", "list", "--porcelain"],
        capture_output=True,
        text=True,
        check=True,
    )
    first_line = result.stdout.splitlines()[0]
    return Path(first_line.removeprefix("worktree "))


def load_worktreerc(main_root: Path) -> dict:
    rc = main_root / ".worktreerc.yml"
    if not rc.exists():
        rc = main_root / ".worktreerc.yaml"
    if not rc.exists():
        return {}
    try:
        data = yaml.safe_load(rc.read_text())
    except yaml.YAMLError as e:
        raise click.ClickException(f"Failed to parse {rc.name}: {e}")
    if not isinstance(data, dict):
        return {}
    return data.get("worktree", {}) or {}


@click.group()
def cli():
    pass


@cli.command()
@click.argument("branch_name")
@click.option(
    "--parent-dir",
    type=click.Path(exists=True, file_okay=False, path_type=Path),
    default=None,
    help="Directory in which to create the worktree (default: parent of repo root).",
)
def create(branch_name: str, parent_dir: Path | None):
    """Create an isolated git worktree for BRANCH_NAME."""
    result = run(["git", "rev-parse", "--show-toplevel"])
    if result.returncode != 0:
        json_output("error", message="Not inside a git repository.")
    repo_root = Path(result.stdout.strip())

    default_branch = get_default_branch()

    result = run(["git", "branch", "--show-current"])
    current_branch = result.stdout.strip()
    if current_branch != default_branch:
        json_output("wrong_branch", current_branch=current_branch, default_branch=default_branch)

    result = run(["git", "fetch", "origin", default_branch, "--quiet"])
    if result.returncode != 0:
        json_output("error", message=f"Failed to fetch origin/{default_branch}. Check your network connection.")

    local_sha = run(["git", "rev-parse", default_branch]).stdout.strip()
    remote_sha = run(["git", "rev-parse", f"origin/{default_branch}"]).stdout.strip()
    if local_sha != remote_sha:
        json_output("behind_origin", default_branch=default_branch)

    if parent_dir is None:
        parent_dir = repo_root.parent
    sanitized = branch_name.replace("/", "-")
    worktree_path = parent_dir / sanitized

    if worktree_path.exists():
        json_output("error", message=f"Path already exists: {worktree_path}")

    result = run(["git", "worktree", "add", str(worktree_path), "-b", branch_name])
    if result.returncode != 0:
        stderr = result.stderr.strip()
        json_output("error", message=f"git worktree add failed: {stderr}")

    json_output(
        "success",
        worktree_path=str(worktree_path),
        branch=branch_name,
        default_branch=default_branch,
        base_sha=local_sha,
    )


@cli.command()
@click.argument("worktree_path", type=click.Path(exists=True, file_okay=False, path_type=Path))
def sync(worktree_path: Path):
    """Copy config files from main worktree into WORKTREE_PATH."""
    try:
        main_root = get_main_worktree()
    except (subprocess.CalledProcessError, IndexError):
        raise click.ClickException("Could not determine main worktree. Are you in a git repository?")

    if main_root.resolve() == worktree_path.resolve():
        click.echo("Already in main worktree, nothing to sync.")
        return

    config = load_worktreerc(main_root)
    copy_patterns = config.get("copy", []) or []
    if not copy_patterns:
        click.echo("No .worktreerc.yml/.yaml found or no copy patterns defined.")
        return

    click.echo(f"Syncing from {main_root} into {worktree_path}:")
    for pattern in copy_patterns:
        for source in main_root.glob(pattern):
            relative = source.relative_to(main_root)
            if relative.name in (".worktreerc.yml", ".worktreerc.yaml"):
                continue
            dest = worktree_path / relative
            if dest.exists():
                continue
            dest.parent.mkdir(parents=True, exist_ok=True)
            if source.is_dir():
                shutil.copytree(source, dest)
            else:
                shutil.copy2(source, dest)
            click.echo(f"  copied {relative}")
    click.echo("Done.")


@cli.command("run-hooks")
@click.argument("worktree_path", type=click.Path(exists=True, file_okay=False, path_type=Path))
def run_hooks(worktree_path: Path):
    """Run post-create hook commands in WORKTREE_PATH."""
    try:
        main_root = get_main_worktree()
    except (subprocess.CalledProcessError, IndexError):
        raise click.ClickException("Could not determine main worktree. Are you in a git repository?")

    config = load_worktreerc(main_root)
    commands = config.get("post_create", []) or []
    if not commands:
        click.echo("No post_create hooks defined, skipping.")
        return

    env = {k: v for k, v in os.environ.items() if k != "VIRTUAL_ENV"}

    for command in commands:
        click.echo(f"Running: {command}")
        result = subprocess.run(command, shell=True, cwd=worktree_path, env=env)
        if result.returncode != 0:
            click.echo(f"Hook failed (exit {result.returncode}): {command}")
            sys.exit(1)

    click.echo("All hooks completed successfully.")


if __name__ == "__main__":
    cli()
