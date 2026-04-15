# @carbonid1/claude-config

Shared Claude Code config (hooks, skills, commands) for carbonid1 personal projects, organized as a multi-plugin marketplace so each consumer picks only what it needs.

Distributed as a Claude Code plugin marketplace — not an npm package.

## Install

In any project session:

```
/plugin marketplace add carbonid1/claude-config
/plugin install core@carbonid1           # recommended — the hook that enforces skill evaluation
/plugin install tdd@carbonid1            # if the project uses TDD
/plugin install design-system@carbonid1  # if the project consumes @carbonid1/design-system
/plugin install todo@carbonid1           # if the project tracks todos in Notion
```

Each plugin auto-updates from `main` on next session start.

## Plugins

| Plugin | Contents | When to install |
| --- | --- | --- |
| `core` | `skill-forced-eval-hook.sh` — forces explicit skill evaluation on every `UserPromptSubmit` | Every project. Makes skill triggering reliable. |
| `tdd` | TDD workflow skill (red-green-refactor, Storybook/Vitest/E2E guidance) | Projects that want consistent testing conventions. |
| `design-system` | Component + design-pattern skill for `@carbonid1/design-system` consumers | Projects that consume `@carbonid1/design-system`. |
| `todo` | Notion-backed task management skill. Reads project name from `.claude/carbonid1.json`. | Projects whose todos live in the shared Eng Projects Notion DB. |

### `todo` project config

The `todo` skill expects a per-repo config at `.claude/carbonid1.json`:

```json
{
  "notion": { "project": "InkVoice" }
}
```

The value of `notion.project` must match the exact Notion Project display name. This is the only project-specific string the skill needs.

## What's intentionally NOT here

- **Rules** (`.claude/rules/`) — Claude Code plugins don't support `rules/`. Ambient rules stay per-repo.
- **Project-specific skills** (e.g., `voice-management`, `electron`) — stay in their respective project's `.claude/skills/`.

## Layout

```
claude-config/
├── .claude-plugin/
│   └── marketplace.json          # lists every plugin in this marketplace
└── plugins/
    ├── core/
    │   ├── .claude-plugin/plugin.json
    │   └── hooks/
    ├── tdd/
    │   ├── .claude-plugin/plugin.json
    │   └── skills/tdd/
    ├── design-system/
    │   ├── .claude-plugin/plugin.json
    │   └── skills/design-system/
    └── todo/
        ├── .claude-plugin/plugin.json
        └── skills/todo/
```
