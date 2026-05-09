
# Phase 717 Inspection Modal Anchor Discovery

Purpose:

- Stop speculative inspection-modal patching after two safe refusals.

- Identify the exact event-listener/control-binding shape in public/js/phase530_visible_panels_bridge.js.

- Preserve the current stable checkpoint before retrying the implementation.

Current checkpoint:

- HEAD expected: b25e7532 or later

- External backup captured source-b25e7532.tar.gz

- No successful inspection-modal source mutation has been committed yet

Next rule:

- Do not attempt the modal patch again until the exact click-binding anchor is confirmed from source output.

