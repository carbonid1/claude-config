---
name: design-system
description: 'Shared UI components and design patterns for carbonid1 apps built on @carbonid1/design-system. ALWAYS use when building UI, creating components, adding dropdowns, selects, tooltips, icons, toasts, context menus, or any interactive element. Use when choosing between native HTML elements and custom components. Also use when working with skeletons, loading states, layout shifts, or async-loaded UI elements. Triggers on: dropdown, select, tooltip, tag, badge, icon, component, UI, design system, shared component, skeleton, loading state, layout shift, context menu, right-click menu, button, theme, palette.'
---

# Design System

Primitives live in `@carbonid1/design-system`. **Check the package's exports and types before building anything new.** This file is direction and taste, not API reference — the types are the docs.

```ts
import {
  Button, Kbd, ProgressRing, Slider, Switch,
  ContextMenu, Select, Tooltip,
  Toaster, toast,
  ThemeProvider, ThemeCycler, useTheme,
  cn, getModKey,
} from '@carbonid1/design-system'
```

Palettes are chosen by importing one theme CSS per app: `@carbonid1/design-system/themes/reader` (InkVoice) or `/themes/dashboard` (CoI Calculator).

If you're editing `@carbonid1/design-system` itself (adding a primitive, changing a token), read that package's `CLAUDE.md` — this file is for *using* the design system, not building it.

## Core rules

- Never use native `<select>` — use `Select`
- Never build a tooltip, context menu, or toast from scratch — use `Tooltip`, `ContextMenu`, `toast()`
- All icons from `lucide-react` — search `lucide.dev/icons` before creating anything custom. If nothing fits, build via Lucide's `Icon` + `iconNode`, don't reach for another library.
- All color through semantic tokens — no hardcoded Tailwind color classes. See [references/theming.md](references/theming.md).
- Tooltip: rely on defaults (`position="top"`, `delay={200}`). Only override when the default is wrong (e.g. header → `position="bottom"`, data-viz progressive disclosure → `delay={600}`). When a tooltip trigger also opens a popover, pass `disabled={open}`.
- Icon toggle state: `<Icon fill={active ? 'currentColor' : 'none'} />` — not two different components.

## Visual Language

- **Discrete elements** — rows/cards use `rounded-lg` with `space-y-1` gaps, never flat lists with hairline dividers
- **Selection** — `bg-primary/10` tint + `ring-1 ring-primary/20`, never border-left accents
- **Hover reveal** — action buttons use `opacity-0 group-hover:opacity-100 group-focus-within:opacity-100` with outer row `hover:bg-accent`. The `group-focus-within` is required — without it, keyboard users tab to an invisible button.
- **Metadata** — badge/chip components, never comma-separated text
- **Touch targets** — icon buttons `p-1.5` minimum, icons `w-4 h-4` minimum
- **Avatars** — only with real images, no letter/initial placeholders

## Destructive Actions

Two tiers. Pick by how hard the action is to redo, not how scary it feels.

| Severity         | Pattern                             | Example                              |
| ---------------- | ----------------------------------- | ------------------------------------ |
| **Hard to redo** | Undo toast (5s + Cmd/Ctrl+Z)        | Delete a record, remove history item |
| **Easy to redo** | No confirmation                     | Toggle flag, remove a tag            |

**Undo toast:** action executes immediately → toast with description `${getModKey()}+Z to undo` + "Undo" action button (5s auto-dismiss) → store holds `lastDeleted` for restoration → global `mod+z` hotkey via `react-hotkeys-hook` → sequential deletes overwrite the buffer (only latest is undoable). Never add a modal confirmation for hard-to-redo actions — the undo toast is the confirmation.

## Layout Stability

Skeleton → real UI transitions must not shift layout. The skeleton is a dimensional contract.

- Skeletons match real UI structure, counts, heights, spacing. Update the skeleton when the real UI changes.
- Async elements that always render (selectors, user controls) show a same-sized placeholder while loading — never `null`.
- Doesn't apply to user-triggered UI (modals, drawers, toasts) or conditional banners — these are unpredictable by nature.

## Theming

`ThemeProvider` wraps the app (toggles `.dark` via `next-themes`). `ThemeCycler` mounts once to register `Shift+T` for cycling system → light → dark. `useTheme` is the next-themes re-export for programmatic access.

Both palettes define the same token names on `:root` + `.dark`, so primitive code and consumer code don't care which palette is active.
