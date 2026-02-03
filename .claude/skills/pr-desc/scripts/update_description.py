#!/usr/bin/env python3
"""Update the PR description."""

import argparse
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser(description="Update PR description")
    parser.add_argument("--body", required=True, help="New PR body")
    args = parser.parse_args()

    result = subprocess.run(
        ["gh", "pr", "edit", "--body", args.body],
        check=False,
    )
    sys.exit(result.returncode)


if __name__ == "__main__":
    main()
