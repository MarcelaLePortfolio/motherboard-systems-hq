# Phase 625 Dashboard Task Render Target

## Confirmed target
public/js/dashboard-tasks-widget.js

## Key render + task mapping area
17:    "[data-tasks-widget]",
23:  const TASK_EVENT_DEBOUNCE_MS = 1000;
64:        <div data-tasks-shell="1">
65:          <div data-tasks-error></div>
66:          <div data-tasks-list></div>
73:    const shell = mount.querySelector('[data-tasks-shell="1"]');
77:      errorEl: shell?.querySelector("[data-tasks-error]") || null,
78:      listEl: shell?.querySelector("[data-tasks-list]") || null,
94:  function render() {
154:        state.tasks = (data.tasks || []).map((t) => ({
227:  function renderRunsPanel(root) {
357:    function renderRows(rows) {
427:    scheduleFetchTasks(TASK_EVENT_DEBOUNCE_MS);

## Conclusion
Next safe patch should be limited to public/js/dashboard-tasks-widget.js.
It should preserve existing polling/SSE behavior and only add read-only guidance rendering when guidance exists on task payloads.
