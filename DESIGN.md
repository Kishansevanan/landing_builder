# Landing Builder — Design System

**Direction:** Warm Precision  
**Tagline:** "Anyone can build a beautiful page in minutes."  
**Version:** 1.0 · July 2026

---

## Philosophy

Warm Precision is the gap in the landing-page-builder market. Most builders are either clinical (Webflow, Framer) or busy (Wix, Squarespace). Landing Builder is for the person who wants a beautiful page without becoming a designer — the interface should feel calm, capable, and warm.

**Three principles:**
1. **Calm** — no visual noise; whitespace earns its place
2. **Precise** — pixel-perfect spacing, consistent radius, intentional hierarchy
3. **Warm** — off-white grounds, earthy teal, type that feels human not sterile

---

## Color

| Token | Hex | Usage |
|---|---|---|
| `--canvas` | `#F9F9F7` | Page ground — warm off-white, the base of everything |
| `--surface` | `#FFFFFF` | Cards, panels, input backgrounds |
| `--ink` | `#1A1A17` | Primary text — warm near-black with a slight yellow cast |
| `--teal` | `#0a7065` | Brand accent — deep earthy teal, CTAs, selected states |
| `--teal-dim` | `#D4F0EC` | Teal at 10% — focus rings, hover fills, selection backgrounds |
| `--teal-mid` | `#A8DFD7` | Mid teal — active borders, strong teal fills without full saturation |
| `--fog` | `#E3E3DF` | Borders, dividers, inactive tabs — warm, not cold grey |
| `--stone` | `#6B6B64` | Secondary text, labels, placeholders |
| `--red` | `#C0392B` | Destructive actions, error states |
| `--red-dim` | `#FCECEA` | Error backgrounds |
| `--amber` | `#B45309` | Warning states (autosave pending, publishing) |
| `--amber-dim` | `#FEF3C7` | Warning backgrounds |

### Usage rules
- The teal `#0a7065` is the **only** accent hue. No secondary accent, no rainbow of functional colors.
- Semantic colors (red, amber) are purely functional — they signal state, not brand.
- Never place `--stone` text on `--fog` backgrounds (contrast too low).
- Selection state = `--teal` border + `--teal-dim` fill. Consistent everywhere.

---

## Typography

**Face:** Plus Jakarta Sans (single family)  
**Weights used:** 400 (body), 500 (UI labels), 600 (subheadings, chips), 700 (headings), 800 (display)  
**Load:** Self-hosted via asset pipeline or Google Fonts: `family=Plus+Jakarta+Sans:wght@400;500;600;700;800`

### Type scale

| Role | Size | Weight | Leading | Tracking | Usage |
|---|---|---|---|---|---|
| Display | 48px | 800 | 1.0 | −0.04em | Hero headlines, marketing copy |
| Heading 1 | 32px | 700 | 1.2 | −0.03em | Page titles (`<h1>My Pages</h1>`) |
| Heading 2 | 24px | 700 | 1.25 | −0.02em | Section headers |
| Heading 3 | 18px | 600 | 1.35 | −0.01em | Card titles, sidebar sections |
| Body | 16px | 400 | 1.65 | — | All running text |
| Small | 14px | 400 | 1.55 | — | Metadata, secondary copy |
| Label | 11px | 600 | — | +0.09em | Uppercase section labels, `text-transform: uppercase` |

### Tailwind v4 note

Tailwind v4 resets all headings to `font-size: inherit; font-weight: inherit`. Apply the type scale explicitly:

```css
/* application.tailwind.css */
@layer base {
  h1 { font-size: 2rem; font-weight: 700; line-height: 1.2; letter-spacing: -0.03em; }
  h2 { font-size: 1.5rem; font-weight: 700; line-height: 1.25; letter-spacing: -0.02em; }
  h3 { font-size: 1.125rem; font-weight: 600; line-height: 1.35; letter-spacing: -0.01em; }
}
```

---

## Spacing

Base unit: **4px**. All spacing values are multiples of 4.

| Token | Value | Usage |
|---|---|---|
| `space-1` | 4px | Tight gaps (icon + label) |
| `space-2` | 8px | Inner padding on small components |
| `space-3` | 12px | Default component padding |
| `space-4` | 16px | Standard padding, gap between related items |
| `space-6` | 24px | Section padding, card padding |
| `space-8` | 32px | Large gaps, content sections |
| `space-12` | 48px | Page-level padding |
| `space-16` | 64px | Major section breaks |

---

## Border Radius

| Token | Value | Usage |
|---|---|---|
| `radius-sm` | 4px | Badges, small chips, property value inputs |
| `radius-md` | 6px | Buttons, inputs, most interactive elements |
| `radius-lg` | 10px | Cards, panels, browser frames |
| `radius-full` | 9999px | Status badges, pill tags |

---

## Shadows

```css
--shadow-sm: 0 1px 3px rgba(26,26,23,.07);
--shadow-md: 0 2px 10px rgba(26,26,23,.09);
--shadow-lg: 0 4px 24px rgba(26,26,23,.11), 0 8px 40px rgba(26,26,23,.07);
```

The shadow tint uses `--ink` at low opacity, not pure black — keeps shadows warm.

---

## Components

### Buttons

```
Primary    background: --teal; color: white
Secondary  background: --surface; border: --fog; color: --ink
Ghost      background: transparent; color: --stone; hover: --fog bg
Danger     background: --red; color: white
```

Padding: `8px 16px` (default), `5px 10px` (sm), `11px 20px` (lg)  
Font: 14px / 600  
Radius: `--radius-md`  
Transition: `background .1s, border-color .1s`

### Inputs

Default border: `--fog`  
Focus border: `--teal` + `box-shadow: 0 0 0 3px --teal-dim`  
Error border: `--red`  
Disabled: `--canvas` background, `--stone` text  
Font: 14px / 400  
Padding: `8px 11px`

### Status Badges

Rounded pill (`border-radius: 9999px`), 12px / 600  
- Draft: `--fog` bg + `--stone` text
- Published: `--teal-dim` bg + `--teal` text
- Error: `--red-dim` bg + `--red` text
- Warning: `--amber-dim` bg + `--amber` text

### Element Type Chips (Sidebar)

Default: `--surface` bg, `--fog` border  
Hover / Active: `--teal-dim` bg, `--teal` border and text  
Icon: 18×18px, `--fog` bg, `--stone` text → `rgba(10,112,101,.15)` bg, `--teal` text when active

---

## Layout

### Builder shell

```
┌─ Top bar (50px) ─────────────────────────────────────────────┐
│  [icon] landing_builder  |  Page name       Draft  [Publish] │
├─ Sidebar (216px) ──┬─ Canvas (flex:1) ──────────────────────┤
│  ELEMENTS          │                                          │
│  T  Text           │   (dot grid 24×24px)                    │
│  H  Heading        │                                          │
│  [_] Button        │   ┌ Heading element (selected) ──────┐  │
│  ▣  Image          │   │ selected: teal border + handles   │  │
│  — Divider         │   └────────────────────────────────── ┘  │
│                    │                                          │
│  ──────────────    │   ┌ Text block ─────────────────────┐   │
│  PROPERTIES        │   │ body copy here                   │   │
│  X     48          │   └──────────────────────────────────┘   │
│  Y     56          │                                          │
│  Width 520         │   ┌ Button ────────────────────────┐    │
│  Font  28          │   │ Shop Now                        │    │
└────────────────────┴──────────────────────────────────────────┘
```

- Top bar: `height: 56px`, `background: --surface`, `border-bottom: 1px solid --fog`
- Sidebar: `width: 216px`, `background: --surface`, `border-right: 1px solid --fog`
- Canvas: `background: --canvas`, dot grid via `radial-gradient(circle, --fog 1px, transparent 1px)` at 24px intervals
- Canvas elements: `position: absolute`, white background, `--fog` border
- Selected element: `--teal` 1px border + `0 0 0 2px --teal-dim` box-shadow + 8px corner handles

### Pages index layout

- App nav: `height: 50px`
- Content: centered, `max-width: 720px`
- Page list: flex column with 1px `--fog` gap between rows on `--fog` background (creates hairline separator effect)

---

## Known Issues to Fix

These audit findings should be resolved before the design system is considered applied:

| ID | File | Issue | Fix |
|---|---|---|---|
| F-001 | `application.tailwind.css` | `.btn` class undefined — sidebar buttons render at 160×24px | Define `.btn` in `@layer components` |
| F-002 | `application.tailwind.css` | Tailwind v4 resets h1–h6 to body size | Add heading scale to `@layer base` |
| F-003 | `Builder.vue` | `watch(layout, autosave, {deep:true})` fires on mount → 422 | Add `{ immediate: false }` |
| F-004 | `Builder.vue` | New elements all start at `top:20px, left:20px` → overlap | Stagger placement (e.g. offset by element count × 20px) |
| F-005 | `Builder.vue` | No back link from builder to pages index | Add `← My Pages` link to top bar |
| F-006 | `Canvas.vue` | Delete button is 20×20px — too small to hit | Increase to at least 28×28px |
| F-007 | `Canvas.vue` | No empty state when canvas has no elements | Add centered prompt: "Click an element in the sidebar to add it" |
| F-008 | `pages/index.html.erb` | Bare `<h1>` + unstyled page list | Apply layout + heading scale from this design system |

---

## CSS Implementation

Add to `app/assets/stylesheets/application.tailwind.css`:

```css
@import "tailwindcss";

@layer base {
  h1 { font-size: 2rem;    font-weight: 700; line-height: 1.2;  letter-spacing: -0.03em; color: #1A1A17; }
  h2 { font-size: 1.5rem;  font-weight: 700; line-height: 1.25; letter-spacing: -0.02em; color: #1A1A17; }
  h3 { font-size: 1.125rem;font-weight: 600; line-height: 1.35; letter-spacing: -0.01em; color: #1A1A17; }
}

@layer components {
  .btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 8px 16px;
    border-radius: 6px;
    font-size: 14px;
    font-weight: 600;
    font-family: inherit;
    cursor: pointer;
    border: 1px solid transparent;
    transition: background .1s, border-color .1s;
    line-height: 1.4;
  }
  .btn-primary {
    background: #0a7065;
    color: white;
    border-color: #0a7065;
  }
  .btn-primary:hover { background: #085E53; border-color: #085E53; }
  .btn-secondary {
    background: white;
    color: #1A1A17;
    border-color: #E3E3DF;
  }
  .btn-secondary:hover { border-color: #6B6B64; }
  .btn-ghost {
    background: transparent;
    color: #6B6B64;
    border-color: transparent;
  }
  .btn-ghost:hover { background: #E3E3DF; color: #1A1A17; }
}
```

---

## Vue / JS Conventions

### Autosave watch

```js
// Correct — does not fire on mount
watch(layout, autosave, { deep: true, immediate: false })
```

### Element stagger

```js
function addElement(type) {
  const offset = layout.value.length * 20
  layout.value.push({
    type,
    top: `${20 + offset}px`,
    left: `${20 + offset}px`,
    width: '200px',
  })
}
```

---

*Generated by gstack /design-consultation · Warm Precision v1 · July 2026*
