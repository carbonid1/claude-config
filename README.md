# @carbonid1/claude-config

Shared Claude Code config (hooks, skills, commands) for carbonid1 personal projects.

Distributed as a Claude Code plugin marketplace — not an npm package.

## Install

In any project session:

```
/plugin marketplace add carbonid1/claude-config
/plugin install carbonid1@carbonid1
```

Tracks `main` — new content lands automatically on next session start.

## What's here

| Type | Item | Description |
| --- | --- | --- |
| hook | `skill-forced-eval-hook.sh` | Forces explicit skill evaluation on every `UserPromptSubmit` |

More to come as project-level `.claude/` configs surface shared patterns.

## What's intentionally NOT here

- **Rules** (`.claude/rules/`) — Claude Code plugins don't support `rules/`. Each project keeps its own rules.
- **Project-specific skills** (e.g., `voice-management`, `electron`, `inkvoice-design-system`) — stay in their respective project's `.claude/skills/`.
- **User-scope skills** (e.g., `tdd` in `~/.claude/skills/`) — already globally available, no need to package.

## Layout

```
claude-config/
├── .claude-plugin/
│   ├── plugin.json         # plugin manifest
│   └── marketplace.json    # marketplace manifest (single-plugin marketplace)
├── hooks/
│   ├── hooks.json          # event → command wiring
│   └── *.sh                # hook scripts
└── README.md
```
