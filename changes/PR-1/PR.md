# Make the hero "Submit Project" button full-width and easy to tap on mobile

## Summary

The main call to action on the ShipFest 2026 homepage was a small inline button (about 35px tall), which is below the recommended 44–48px minimum touch target on phones. This PR makes the hero **Submit Project** button full-width on mobile with a 52px tap target, and keeps a tidy auto-width button on tablet and desktop.

## Changes

- `styles.css`
  - `.hero-actions` now stacks vertically on small screens, so the button can take the full width, with the "Read the rules" link centred underneath.
  - New `.hero-cta` rule: `width: 100%`, `min-height: 52px`, larger padding and font size for mobile.
  - At `min-width: 640px` the actions go back to a single row and the button returns to auto width with a 48px minimum height.

No HTML or JavaScript changes. The button already had the `hero-cta` class.

## Testing

- ✅ `node --test`: all 12 tests pass (no behaviour changes).
- ✅ Checked at 390×844 (iPhone 14) and 1280×800. The button spans the content width on mobile and is a normal inline button on desktop.
- ✅ Focus ring and hover states are unchanged.

## Risk

Low. CSS only, limited to the hero actions row.
