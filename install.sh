#!/bin/bash
# install.sh — Install work-backend-feat skill by copying files to ~/.claude/skills/
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_NAME="work-backend-feat"
CLAUDE_SKILLS="${HOME}/.claude/skills"
TARGET="$CLAUDE_SKILLS/$SKILL_NAME"

mkdir -p "$CLAUDE_SKILLS"

if [ -e "$TARGET" ]; then
  echo "⚠ '$SKILL_NAME' already exists at $TARGET"
  echo "  To reinstall, remove it first: rm -rf $TARGET"
  exit 1
fi

mkdir -p "$TARGET/references"
cp "$SKILL_DIR/SKILL.md" "$TARGET/SKILL.md"
cp "$SKILL_DIR/references/spec-template.md" "$TARGET/references/spec-template.md"
cp "$SKILL_DIR/references/plan-template.md" "$TARGET/references/plan-template.md"

echo "✓ Installed: $SKILL_NAME → $TARGET"
echo ""
echo "Start Claude Code and try: \"새로운 API 엔드포인트 추가해줘\""
