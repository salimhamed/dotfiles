#!/usr/bin/env python3
"""Create a pull request with the given title and body."""

import argparse
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser(description="Create a pull request")
    parser.add_argument("--title", required=True, help="PR title")
    parser.add_argument("--body", required=True, help="PR body")
    args = parser.parse_args()

    result = subprocess.run(
        ["gh", "pr", "create", "--title", args.title, "--body", args.body],
        check=False,
    )
    sys.exit(result.returncode)


if __name__ == "__main__":
    main()
