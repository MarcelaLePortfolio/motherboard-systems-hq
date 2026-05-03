# Option 1 – Top Row Vertical Split Alignment (Planning Note)

Context: Matilda Chat Phase 2 on branch `feature/v11-dashboard-bundle`.

Goal for Option 1
-----------------
Gradually refine the dashboard so that:

- The **vertical split line** between the left and right halves of the dashboard
  is consistent across:
  - Matilda Chat Console (left)
  - Project Visual Output (left)
  - Task Delegation (right)
  - Atlas Subsystem Status (right)
  - System Reflections (right)
  - Critical Ops Alerts (right)
- The left and right columns feel like two coherent rails that share one
  common center split, rather than a set of loosely aligned cards.

Current State Snapshot
----------------------
As of commit `b91a83ea` and documented in `MATILDA_CHAT_LAYOUT_STATUS.md`:

- **Matilda Chat Console** and **Project Visual Output**:
  - Styled and visually stable.
  - Widths are now set to `width: 100%` / `max-width: 100%`, fully occupying
    their available left-column space.
- **Right-side cards** (Task Delegation, Atlas, System Reflections, Critical Ops):
  - Use the `.delegation-column-card` class with `width: 100%` / `max-width: 100%`
    so they fully occupy the right-column space.
- Net effect:
  - Left and right columns visually meet near the center of the dashboard in the
    rows where both sides are present (Matilda Chat + Task Delegation, Project
    Visual Output + System Reflections / Critical Ops).

Why This Note Exists
--------------------
Recent iterations on layout involved several CSS and JS experiments that
momentarily disturbed the dashboard’s structure. To avoid reintroducing layout
instability, **Option 1** is intentionally captured as a planning step:

- No further CSS/JS grid mutations are applied at this stage.
- We acknowledge the current layout as a *stable baseline* with acceptable
  left/right alignment.
- Any future refinement of the **top metrics row** or global grid alignment
  will be done:
  - Directly in the core dashboard layout CSS (e.g., the grid/flex container
    that controls the main content rows), and
  - Only after inspecting the underlying HTML/CSS structure, so that changes
    are structural instead of applied via helper scripts.

Next Step After Option 1
------------------------
With this baseline recorded, the next refinements (Options 2–4) will be:

2. **Add breathing room between left and right columns**
   - Introduce an explicit, consistent column gap for a more polished, modern feel.

3. **Add responsive behavior**
   - Ensure the layout adapts cleanly for narrower viewports, stacking cards in
     a controlled way.

4. **Add subtle animations**
   - e.g., fade/slide-in transitions as Matilda Chat and Project Visual Output
     load or update.

This file serves as the anchor note for Option 1 so we can safely iterate on
Options 2–4 without losing track of the current, working layout.
