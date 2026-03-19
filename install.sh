#!/bin/bash
# install.sh — Install work-backend-feat skill as a symlink to ~/.claude/skills/
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_NAME="work-backend-feat"
CLAUDE_SKILLS="${HOME}/.claude/skills"

mkdir -p "$CLAUDE_SKILLS"

if [ -e "$CLAUDE_SKILLS/$SKILL_NAME" ]; then
  echo "⚠ '$SKILL_NAME' already exists at $CLAUDE_SKILLS/$SKILL_NAME"
  echo "  To reinstall, remove it first: rm $CLAUDE_SKILLS/$SKILL_NAME"
  exit 1
else
  ln -s "$SKILL_DIR" "$CLAUDE_SKILLS/$SKILL_NAME"
  echo "✓ Installed: $SKILL_NAME → $SKILL_DIR"
  echo ""
  echo "Start Claude Code and try: \"Add a new API endpoint\""
fi
