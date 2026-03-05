#!/usr/bin/env bash
set -euo pipefail

LUA_TARGETS=(
  "$HOME/.config/lazyvim/"
  "$HOME/.config/nvim/"
  "$HOME/.nvim.lua"
)

SHELL_TARGETS=(
  "$HOME/.config/yadm/bootstrap##distro.Ubuntu"
  "$HOME/.config/yadm/bootstrap##os.Darwin"
)

usage() {
  echo "Usage: lint-check.sh <command>"
  echo ""
  echo "Commands:"
  echo "  format       Auto-format all files (Lua + shell)"
  echo "  check        Check formatting without modifying files"
  echo "  lint         Run linters (luacheck + shellcheck)"
  echo "  all          Run check + lint"
  echo ""
  echo "  lua-format   Auto-format Lua files with stylua"
  echo "  lua-check    Check Lua formatting"
  echo "  lua-lint     Run luacheck"
  echo ""
  echo "  sh-format    Auto-format shell files with shfmt"
  echo "  sh-check     Check shell formatting"
  echo "  sh-lint      Run shellcheck"
  exit 1
}

# Lua commands
cmd_lua_format() {
  echo "Formatting Lua files with stylua..."
  stylua "${LUA_TARGETS[@]}"
  echo "Done."
}

cmd_lua_check() {
  echo "Checking Lua formatting with stylua..."
  stylua --check "${LUA_TARGETS[@]}"
  echo "Lua formatting OK."
}

cmd_lua_lint() {
  echo "Linting Lua files with luacheck..."
  luacheck "${LUA_TARGETS[@]}"
  echo "Lua linting OK."
}

# Shell commands
cmd_sh_format() {
  echo "Formatting shell files with shfmt..."
  shfmt -i 4 -w "${SHELL_TARGETS[@]}"
  echo "Done."
}

cmd_sh_check() {
  echo "Checking shell formatting with shfmt..."
  shfmt -i 4 -d "${SHELL_TARGETS[@]}"
  echo "Shell formatting OK."
}

cmd_sh_lint() {
  echo "Linting shell files with shellcheck..."
  shellcheck "${SHELL_TARGETS[@]}"
  echo "Shell linting OK."
}

# Combined commands
cmd_format() {
  cmd_lua_format
  echo ""
  cmd_sh_format
}

cmd_check() {
  cmd_lua_check
  echo ""
  cmd_sh_check
}

cmd_lint() {
  cmd_lua_lint
  echo ""
  cmd_sh_lint
}

cmd_all() {
  cmd_check
  echo ""
  cmd_lint
}

case "${1:-}" in
  format)     cmd_format ;;
  check)      cmd_check ;;
  lint)       cmd_lint ;;
  all)        cmd_all ;;
  lua-format) cmd_lua_format ;;
  lua-check)  cmd_lua_check ;;
  lua-lint)   cmd_lua_lint ;;
  sh-format)  cmd_sh_format ;;
  sh-check)   cmd_sh_check ;;
  sh-lint)    cmd_sh_lint ;;
  *)          usage ;;
esac
