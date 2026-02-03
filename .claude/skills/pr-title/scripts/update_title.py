#!/usr/bin/env python3
"""Update the PR title."""

import argparse
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser(description="Update PR title")
    parser.add_argument("--title", required=True, help="New PR title")
    args = parser.parse_args()

    result = subprocess.run(
        ["gh", "pr", "edit", "--title", args.title],
        check=False,
    )
    sys.exit(result.returncode)


if __name__ == "__main__":
    main()
