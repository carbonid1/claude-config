# Color & Theming

## Philosophy

Tokens represent semantic roles, not fixed hues. Each theme picks the best hue for that role in its own context — light and dark themes may use entirely different hue families for the same token. The design system is app-agnostic: swap the token values, everything updates.

We use shadcn's token naming convention but own all color values. When pulling a new shadcn component, replace any generated color values with our hand-tuned tokens. This follows shadcn's own approach (~99% token-driven) as validation, not as a dependency.

## Palettes

`@carbonid1/design-system` ships multiple palettes — currently `reader` (InkVoice) and `dashboard` (CoI Calculator, admin-style UIs). Both define the same token names on `:root` + `.dark`; consumers choose one by importing the matching CSS:

```ts
import '@carbonid1/design-system/themes/reader'
// or
import '@carbonid1/design-system/themes/dashboard'
```

Primitives must render correctly under every palette × light/dark combination — that's the contract. Because both palettes hit the same token names, primitive code stays palette-agnostic and consumer code doesn't change when switching.

## Rules

- **All color through tokens.** Every color that appears in themed UI must reference a CSS variable. No hardcoded Tailwind color classes (`blue-500`, `amber-400`, `gray-300`) for meaning-bearing colors.
- **Hardcoded only when physically fixed.** The only exception: values that must be constant regardless of theme (e.g. `bg-black/10` for modal backdrops). These are rare — 2-3 cases in the entire app.
- **Opacity modifiers work natively.** Tailwind v4 supports `bg-token/20` on any color format including oklch CSS variables. No `color-mix()` workarounds needed.
- **Use enough sub-variants for depth.** Don't squeeze a semantic color into just 2 tokens (base + foreground) when it serves distinct roles — text, background, and border often need different values to look intentional. Use 4-5 sub-variants (e.g. `foreground`, `muted`, `border`) when it gives the area more visual depth. Opacity modifiers on a single base color are a poor substitute for dedicated tokens tuned per role.

## Token Inventory

Tokens are defined in `globals.css` (`:root` + `.dark`), bridged in `@theme inline` block, consumed as Tailwind utilities.

### Base tokens (from shadcn naming)

| Token           | Role                                                            | Sub-variants |
| --------------- | --------------------------------------------------------------- | ------------ |
| `--background`  | Page background                                                 | —            |
| `--foreground`  | Default text                                                    | —            |
| `--card`        | Card surfaces                                                   | foreground   |
| `--popover`     | Popover surfaces                                                | foreground   |
| `--primary`     | Interactive color (buttons, links, selections, focus, progress) | foreground   |
| `--secondary`   | Supporting surfaces                                             | foreground   |
| `--muted`       | De-emphasized surfaces and text                                 | foreground   |
| `--accent`      | Hover/expanded tints                                            | foreground   |
| `--destructive` | Errors, danger                                                  | —            |
| `--border`      | Default borders                                                 | —            |
| `--input`       | Input borders                                                   | —            |
| `--ring`        | Focus rings                                                     | —            |

### Custom tokens

| Token         | Role                                          | Sub-variants              |
| ------------- | --------------------------------------------- | ------------------------- |
| `--highlight` | Emphasis accent (e.g. live cursors, selection highlights) | foreground, muted         |
| `--attention` | Warnings, notices, saved-for-later — "look at this"       | foreground, muted, border |
| `--success`   | Completion, positive outcomes                 | foreground                |

## How to Add a New Semantic Token

1. **Define values** in `globals.css` — both `:root` (light) and `.dark`. Use oklch for perceptual uniformity. Light and dark values may use different hues if the role reads better that way.

   ```css
   :root {
     --my-token: oklch(0.65 0.15 45);
     --my-token-foreground: oklch(0.25 0.05 40);
   }
   .dark {
     --my-token: oklch(0.7 0.12 200);
     --my-token-foreground: oklch(0.95 0.02 195);
   }
   ```

2. **Bridge in `@theme inline`** in `globals.css` so Tailwind generates utilities:

   ```css
   @theme inline {
     --color-my-token: var(--my-token);
     --color-my-token-foreground: var(--my-token-foreground);
   }
   ```

3. **Use in components** via Tailwind classes:
   ```tsx
   <div className="bg-my-token text-my-token-foreground">
   <span className="bg-my-token/10">  // opacity modifier for tints
   ```

## Notes

- **`::selection`** uses solid oklch values, not opacity modifiers — semi-transparent backgrounds create visible seams at line boundaries.
- **Tooltip** uses inverted tokens (`bg-foreground text-background`) since it's a dark-on-light / light-on-dark surface. Kbd badge: `bg-background/15`.
- **DebugPanel** is excluded from token migration — physically fixed terminal aesthetic.
