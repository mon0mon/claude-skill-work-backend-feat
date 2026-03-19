# work-backend-feat

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill that automates the entire backend feature implementation workflow — from requirements gathering to merge.

## Overview

This skill orchestrates a structured, AI-assisted workflow for backend feature development and bug fixes. Each phase includes AI review before user review, so you can focus on key decisions.

### Workflow Phases

```
Phase 1: Requirements Gathering     → Clarify requirements and scope
Phase 2: Spec Document              → Generate and review spec document
Phase 3: AI Review Format           → Structured review with severity levels
Phase 4: Execution Plan             → TDD-based implementation plan
Phase 5: Jira Ticket & Branch       → Create Jira issue and git branch
Phase 6: TDD & Implementation       → Test-first development with code review
Phase 7: Commit & Push              → Structured commits with user approval
Phase 8: Pull Request               → Auto-generated PR description
Phase 9: Merge & Cleanup            → Merge, branch cleanup, Jira completion
```

### Key Features

- **AI Review at every phase** — Spec review, plan review, code review with structured severity levels (CRITICAL / HIGH / MEDIUM / LOW)
- **User approval gates** — Every major step requires `(Y/n)` confirmation before proceeding
- **TDD workflow** — Tests are written before implementation code
- **Progress tracking** — Visual progress bar shows current phase and completion percentage
- **Resume support** — Can resume interrupted workflows from the last checkpoint
- **Jira integration** — Auto-creates tickets, transitions status, links to PRs
- **Spec & plan templates** — Included templates ensure consistency

### AI Review Format

Issues found during review are presented in a structured format:

```
### [P1] Issue Title  [CRITICAL]

**Domain/Context**: Detailed domain description
**Problem**: What the issue is
**Scenario**: When it occurs and what happens

**Solutions**:
  A) Solution description
     - Rationale, Pros, Cons
     - Fitness table (architecture, consistency, complexity, maintainability, performance, testability)
     - Recommendation: Recommended / Not recommended

  B) Alternative solution...

  👉 Recommended: A — One-line reason
```

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- [Atlassian MCP Server](https://github.com/anthropics/claude-code/tree/main/packages/mcp) (for Jira integration)

### Optional Skills

These skills enhance the workflow when installed, but are not required:

| Skill | Phase | Role |
|-------|-------|------|
| `spec-reviewer` | Phase 2 (Spec Review) | Multi-perspective expert review |
| `test-driven-development` | Phase 6 (TDD) | TDD process guidance |
| `requesting-code-review` | Phase 6 (Code Review) | Structured code review |
| `writing-plans` | Phase 4 (Execution Plan) | Systematic plan creation |

## Installation

### Quick Install

```bash
git clone https://github.com/mon0mon/claude-skill-work-backend-feat.git
cd claude-skill-work-backend-feat
./install.sh
```

### Manual Install

```bash
# 1. Clone the repository
git clone https://github.com/mon0mon/claude-skill-work-backend-feat.git ~/path/to/skill

# 2. Create symlink to Claude Code skills directory
mkdir -p ~/.claude/skills
ln -s ~/path/to/skill ~/.claude/skills/work-backend-feat
```

### Verify Installation

After installation, start Claude Code and try:

```
"Add a new API endpoint"
```

The skill triggers on phrases like:
- "Add a feature", "Fix a bug", "Create an API"
- "Add an endpoint", "Add a new domain"
- "Implement this", "Add this", "Create this"

## Project Structure

```
work-backend-feat/
├── SKILL.md                          # Skill definition (main file)
├── README.md                         # This file
├── install.sh                        # Installation script
└── references/
    ├── spec-template.md              # Spec document template
    └── plan-template.md              # Execution plan template
```

## Customization

This skill is designed for **Spring Boot + Hexagonal Architecture** projects with Kotlin, but you can adapt it to your stack:

1. **Architecture conventions** (Phase 6.3.2) — Update hexagonal architecture checks to match your project structure
2. **Test conventions** (Phase 6.1) — Modify test base classes and directory patterns
3. **JPA/DB checks** (Phase 6.3.3-4) — Replace with your ORM-specific checks
4. **Commit message format** (Phase 7) — Change `PS-{number}` to your convention
5. **PR base branch** (Phase 8) — Change `develop` to your default branch
6. **Spec/Plan templates** (references/) — Customize templates to match your team's format

## How It Works

### 1. Trigger

When you ask Claude Code to implement a feature or fix a bug, this skill automatically activates and guides you through the full workflow.

### 2. Structured Phases

Each phase produces artifacts (spec document, execution plan, test code, implementation) with AI review before user approval.

### 3. Documents

The skill generates structured documents:
- **Spec documents** → `docs/workflow/work/backend/spec/`
- **Execution plans** → `docs/workflow/work/backend/plans/`

### 4. Jira Integration

With the Atlassian MCP server configured, the skill automatically:
- Creates Jira issues from specs
- Assigns to the current user
- Transitions status through the workflow
- Closes the ticket on merge

## License

MIT
