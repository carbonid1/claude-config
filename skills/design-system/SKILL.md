---
name: design-system
description: 'Shared UI components and design patterns for carbonid1 apps built on @carbonid1/design-system. ALWAYS use when building UI, creating components, adding dropdowns, selects, tooltips, icons, toasts, or any interactive element. Use when choosing between native HTML elements and custom components. Also use when working with skeletons, loading states, layout shifts, or async-loaded UI elements. Triggers on: dropdown, select, tooltip, tag, badge, icon, component, UI, design system, shared component, skeleton, loading state, layout shift.'
---

# Design System

Primitives live in `@carbonid1/design-system`. Check that package's exports before building anything new — reuse what exists.

```ts
import {
  Button, Kbd, ProgressRing, Slider, Switch,
  Select, Tooltip, Toaster, ThemeProvider, ThemeCycler,
  toast, useTheme, cn, getModKey,
} from '@carbonid1/design-system'
```

## Select

Custom dropdown replacing native `<select>`. **Never use native `<select>` — always use this.**

```
Props:
  value: string
  onChange: (value: string) => void
  options?: SelectOption[]            // flat list
  groups?: SelectGroup[]              // grouped list with headers
  renderOption?: (option, state) => ReactNode  // custom item rendering
  placeholder?: string
  className?: string                  // button styling
  menuClassName?: string              // dropdown menu extra classes (e.g. "right-0")
  onOpenChange?: (open: boolean) => void  // notifies parent of dropdown open/close
  id?: string
  aria-label?: string
```

## Tooltip

Hover/focus tooltip. Wraps a single child.

```
Props:
  label: string
  shortcut?: string
  position?: 'top' | 'bottom'   // default: 'top'
  delay?: number                 // ms before showing, default: 200
  maxWidth?: number
  disabled?: boolean
  children: ReactElement
```

**Rely on defaults** — don't pass `position="top"` since it's the default. Only pass `position="bottom"` when the tooltip is in a header or top-of-page area. Same for `delay` — only pass it when a non-default delay is needed (e.g., `delay={600}` for progressive-disclosure tooltips on data visualizations).

**Popover pattern:** When a tooltip trigger also opens a popover/menu, pass `disabled={open}` to suppress the tooltip while the popover is visible. Without this, the focus event re-shows the tooltip on top of the popover.

## Icons

**Library:** `lucide-react` — import icons directly: `import { Play, Pause, X } from 'lucide-react'`. Browse at `lucide.dev/icons`.

**Toggle pattern:** Use `fill` prop for filled/unfilled state:

```tsx
<Bookmark fill={isActive ? 'currentColor' : 'none'} />
```

If a Lucide icon doesn't exist for a need, create one using Lucide's `Icon` component with `iconNode` prop to stay in the Lucide ecosystem — don't reach for another icon library.

## Color & Theming

Read [references/theming.md](references/theming.md) when choosing colors, adding color to a component, working with theme tokens, or migrating hardcoded color classes. All color in themed UI must go through semantic CSS tokens — no hardcoded Tailwind color classes.

## Visual Language

- **Discrete elements** — rows/cards use `rounded-lg` with `space-y-1` gaps, never flat lists with hairline dividers
- **Selection** — `bg-primary/10` tint + `ring-1 ring-primary/20` outline, never border-left accents
- **Hover reveal** — action buttons use `opacity-0 group-hover:opacity-100 group-focus-within:opacity-100`, outer row gets `hover:bg-accent`. The `group-focus-within` is required so keyboard users can see the button when tabbing to it — without it, the button is invisible but focusable.
- **Destructive actions** — tiered by severity (see Destructive Actions section below)
- **Metadata** — use badge/chip components, never plain comma-separated text
- **Touch targets** — icon buttons minimum `p-1.5`, icons minimum `w-4 h-4`
- **Avatars** — only when real images exist, no letter/initial placeholders

## Toast

`Toaster` is mounted once in the root layout:

```tsx
import { Toaster } from '@carbonid1/design-system'
<Toaster position="bottom-center" />
```

Then call `toast()` from any client component:

```tsx
import { toast } from '@carbonid1/design-system'

toast('Message', {
  description: 'Optional detail',
  action: { label: 'Undo', onClick: () => handleUndo() },
  duration: 5000,
})
```

## Destructive Actions

Two tiers based on severity:

| Severity         | Pattern                             | Example                              |
| ---------------- | ----------------------------------- | ------------------------------------ |
| **Hard to redo** | Undo toast (5s window + Cmd/Ctrl+Z) | Delete a record, remove history item |
| **Easy to redo** | No confirmation                     | Toggle flag, remove a tag            |

### Undo Toast Pattern

For actions that are hard to redo:

1. Action executes immediately
2. Toast appears: title + `${getModKey()}+Z to undo` description + "Undo" action button
3. 5-second auto-dismiss
4. Store holds `lastDeleted` with the deleted item for restoration
5. `mod+z` hotkey (react-hotkeys-hook) triggers undo globally on the page
6. Sequential deletes overwrite undo buffer — only latest is undoable

**Helper:** `getModKey()` from `@carbonid1/design-system` — returns "Cmd" on Mac, "Ctrl" elsewhere.

## Drawers

Side panels that slide in over content.

**Structure:**

- Backdrop: `fixed inset-0 bg-black/30 z-30`, fade in/out via opacity
- Panel: `fixed inset-y-0 {left-0|right-0} w-96 max-w-[85vw] z-40`, slide in/out via translate
- Header: `p-4 border-b`, title + close button wrapped in `Tooltip`
- Scroll area: `overflow-y-auto h-[calc(100%-57px)]`
- Content padding: `pt-1 pb-8` — generous bottom so end-of-list is obvious when scrolling
- Empty state: centered in full scroll height (`flex items-center justify-center h-full`)

**Behavior:**

- `tabIndex={-1}` on panel, auto-focus on open
- `Escape` always closes; feature-specific toggle key closes too
- Backdrop click closes

## Layout Stability

Skeleton → real UI transitions must not cause layout shifts. The skeleton is a dimensional contract for the loaded state.

- **Skeletons match real UI** — same row structure, element count, heights, and spacing. When the real UI changes, update its skeleton to match.
- **Async elements that always appear** (e.g., selectors, user controls) render a same-sized placeholder while loading — never return `null`. Match the loaded element's classes (`px-2 py-1 text-sm rounded` → skeleton with equivalent height/width).
- **Does not apply to** user-triggered UI (modals, drawers, toasts) or conditional banners (errors, recovery prompts) — these are unpredictable by nature and don't need reserved space.

## Focus States

`globals.css` in every consumer app should have a global `focus-visible` rule on all `button`, `[role="button"]`, and `a` elements using `ring-primary` — don't add per-element focus styling unless overriding the color.

## Rules

- Never use native `<select>` — use `Select` from `@carbonid1/design-system`
- Never build a tooltip from scratch — use `Tooltip`
- Use Lucide React for all icons — search `lucide.dev/icons` before creating custom ones
- Never build a page header from scratch — wrap content in a shared header component
- Use `toast()` from `@carbonid1/design-system` for notifications — never build custom toast/snackbar
- Follow the destructive action severity tiers — never add confirmation to low-severity actions, never skip it for high-severity ones
- Use `pt-1 pb-8` on drawer scroll content — never flat `py-*`
- Use semantic color tokens for all colors — no hardcoded Tailwind color classes (see `references/theming.md`)
- Check this file when building any UI element
