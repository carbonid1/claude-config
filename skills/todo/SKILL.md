---
name: todo
description: Manage project todos in Notion. Triggers on "add task", "new todo", "mark done", "complete task", "cancel task", "list todos", "show tasks", "what should I work on", "next task".
---

Manages per-project todos in the Eng Projects Notion database.

## Database Reference

- Data Source: `collection://7e6401c1-dea5-4021-95cb-f9f7c7d1f3d6`
- ID field: `userDefined:ID` (format: `EP-###`, e.g., `EP-455`)

## Setup (run first)

**Read the project name** from `.claude/notion-project` at the current repo root. It's a single-line plain text file containing the exact Notion "Project" property value (e.g., `InkVoice`, `CoI Calculator`). Store it as `$PROJECT` and substitute everywhere this skill says `$PROJECT`.

If `.claude/notion-project` does not exist, stop and ask the user to create it:

```
echo "<Your Notion Project display name>" > .claude/notion-project
```

Then load Notion MCP tools:

```
ToolSearch: select:mcp__notion__notion-search
ToolSearch: select:mcp__notion__notion-fetch
ToolSearch: select:mcp__notion__notion-update-page
ToolSearch: select:mcp__notion__notion-create-pages
```

## Filtering

Notion search API returns cross-project results even with `data_source_url` filtering. Always include `$PROJECT` in search queries and post-filter results by fetching each page and verifying its Project property equals `$PROJECT` before displaying.

## Commands

### Add a task

`/todo add <description>` or `/todo <description>`

Create page with:

- Name: task description
- Project: `$PROJECT`
- Status: Backlog (default), or parse from description (see Status Values below)
- Priority: Medium (default), or parse from description (e.g., "urgent: fix bug")
- Problem Area: infer from keywords (bug, feature, refactor, etc.)

**Example:** `/todo fix audio buffering issue` → infers Priority: Medium, Problem Area: Bug (from "fix")

**Stop after creating.** The whole point of a todo is to defer work for later. After creating the task, confirm it was added and stop — do not research, plan, or begin implementing it. If the user wanted to work on it now, they wouldn't be creating a todo.

### Complete a task

`/todo done <name, partial match, or ID>`

Search for task by name or ID (e.g., `EP-455`). **Do NOT update Status to "Done" immediately.** Instead, ask the user to confirm the task is actually done. Only update after explicit user approval. Example: "Mark EP-455 as Done? (y/n)"

### Cancel a task

`/todo cancel <name, partial match, or ID>`

Update Status to "Cancelled".

### List open tasks

`/todo list`

1. Search with query `$PROJECT` filtered by `data_source_url`
2. Fetch each result with `mcp__notion__notion-fetch` and check Project = `$PROJECT`
3. Discard results from other projects
4. Filter to Status in (To Do, Backlog, Blocked)
5. Display sorted by Priority with ID:

```
EP-455 | Medium | Feature | Kick off design system...
```

### Get next task

`/todo next`

Find highest priority open task and suggest it.

## ID Detection

When user input matches pattern `EP-` followed by digits (e.g., `EP-455`, `EP-123`):

- Search by `userDefined:ID` property instead of name
- The ID is available in fetch results under `userDefined:ID`

## Tool Usage

Use `mcp__notion__notion-search` to find tasks:

- Always include `$PROJECT` in the query string (e.g., `"$PROJECT audio buffering"`)
- Filter by data_source_url: `collection://7e6401c1-dea5-4021-95cb-f9f7c7d1f3d6`

Use `mcp__notion__notion-fetch` to post-filter results:

- Fetch each search result page
- Verify Project property = `$PROJECT` before including in output

Use `mcp__notion__notion-create-pages` to add tasks:

- parent: { data_source_id: "7e6401c1-dea5-4021-95cb-f9f7c7d1f3d6" }
- properties: { Name, Project: `$PROJECT`, Status, Priority, "Problem Area", Notes }

Use `mcp__notion__notion-update-page` to update tasks:

- command: "update_properties"
- properties: { Status: "Done" } or { Status: "Cancelled" }

## Status Values

Valid Notion statuses and their synonyms — always map user language to the exact Notion value:

| Notion Value | Synonyms                                                |
| ------------ | ------------------------------------------------------- |
| Backlog      | backlog, later, someday (default for new tasks)         |
| To Do        | todo, to-do, planned, queued                            |
| On It        | in progress, working on it, started, doing, active, wip |
| Blocked      | blocked, stuck, waiting                                 |
| Done         | done, complete, finished, shipped                       |
| Cancelled    | cancel, cancelled, dropped, wont-do                     |

Never pass user synonyms directly to Notion — resolve to the exact value from the left column.

## Priority Keywords

- urgent, critical, asap → Urgent
- high, important → High
- medium, normal → Medium (default)
- low, later, someday → Low

## Problem Area Keywords

- bug, fix, broken, error → Bug
- feature, add, new, implement → Feature
- ui, ux, design, style → UI improvement
- refactor, cleanup, reorganize → Refactoring
- tool, script, automation → Tools
- ci, cd, pipeline, deploy → CI/CD
- doc, readme, comment → Docs
- build, compile, bundle → Build
