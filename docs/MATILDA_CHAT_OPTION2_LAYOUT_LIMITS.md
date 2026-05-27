# Matilda Chat – Option 2 Layout Limits (Why changes look unchanged)

User observation (visual):  
> "Still looks unchanged, and the code is spilling out of the Critical Ops Alerts container."

## What is happening

Recent commits focused on **matilda-chat.css** to:

- Widen the **Matilda Chat Console** and **Project Visual Output**.
- Add "breathing room" via `max-width: 96%`.
- Fix Critical Ops wrapping with:
  - `word-wrap: break-word;`
  - `overflow-wrap: break-word;`
  - `white-space: pre-wrap;`

However, the **overall column split** and **card positioning** are still controlled by the
core dashboard layout (likely in `css/dashboard.css` and/or the main container structure
in `public/index.html`), not by the Matilda-specific stylesheet.

Because of that:

- Changing widths on `#matilda-chat-container`, `#project-visual-output-card`,
  and `.delegation-column-card` **does not move the true center split**.
- The left and right columns continue to be constrained by the parent grid/flex
  layout, so the visible layout appears essentially the same.
- Critical Ops Alerts text may still appear to "spill" if its container or child
  `pre` elements are styled in another stylesheet that overrides or conflicts with
  the new rules in `matilda-chat.css`.

## Why the dashboard looks unchanged

The vertical split and card alignment are ultimately defined at a higher level:

- The parent grid / flex container that arranges:
  - Left column (Matilda Chat, Project Visual Output)
  - Right column (Task Delegation, Atlas, System Reflections, Critical Ops)
- This higher-level layout is not yet modified. All Option 2 CSS changes have
  been scoped to `matilda-chat.css`, which has **limited authority** over the
  global grid.

As a result:

- The Matilda / Project cards *internally* obey the new widths,
  but the **outer layout** keeps them in the same place.
- The user perceives "unchanged" because the global grid did not move.

## Next required step for real visual change

To actually shift the vertical split and spacing in a visible way, the next work
must be done **in the core layout**, not only in Matilda-specific CSS:

1. Inspect the main layout structure:
   - `public/index.html` (or any dashboard layout partials)
   - `css/dashboard.css` (or equivalent global stylesheet)
2. Identify the container that renders the two main columns:
   - e.g., a `display: grid` with `grid-template-columns`, or a flex container.
3. Apply Option 2 "breathing room" at that level:
   - Adjust `grid-template-columns` ratio or add `column-gap`.
   - Or adjust flex-basis / width for left vs right columns.
4. Only then fine-tune Matilda/Project/Delegation card widths if necessary.

Until that structural pass is done, **additional edits to `matilda-chat.css`
alone will not create meaningful visible change**, even though commits succeed.

## Recommendation

- Treat the current state (commit `b91a83ea` and `d8b52316`) as a **stable baseline**.
- Pause further speculative CSS-only tweaks in `matilda-chat.css`.
- When ready to continue Option 2, start by:
  - Reviewing `css/dashboard.css` and the main container markup.
  - Designing a small, deliberate change to the primary grid/flex layout.
- After that structural change, use `matilda-chat.css` only for local polish,
  not for moving the overall center split.

This file explains why the last few Option 2 commits produced little to no
visible change, and outlines the correct next step for structural alignment.
