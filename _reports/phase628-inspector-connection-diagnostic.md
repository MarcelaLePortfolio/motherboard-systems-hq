# Phase 628 Inspector Connection Diagnostic

## /api/tasks response
{"ok":true,"tasks":[{"id":1,"task_id":"phase626-guidance-visual-test","title":"Phase 626 Guidance Visual Test","status":"completed","claimed_by":null,"updated_at":"2026-05-03T23:01:19.342Z","outcome_preview":null,"explanation_preview":null,"guidance":{"outcome":"Guidance is exposed through /api/tasks for UI verification.","explanation":"This event verifies the read-only guidance surfacing path after Docker and DB recovery.","classification":"warning"}}]}

## Dashboard logs
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=12',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:3000/',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=50',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:3000/',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:3000/',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:3000/',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=50',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:3000/',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=12',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:3000/',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=50',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:3000/',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=50',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:3000/',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=12',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:3000/',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=50',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:3000/',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=50',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:3000/',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=12',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:3000/',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=50',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:3000/',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=50',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:3000/',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: null,
dashboard-1  |   userAgent: 'curl/8.7.1',
dashboard-1  |   accept: '*/*'
dashboard-1  | }


## Inspector script markers
7:  const INSPECTOR_ENDPOINT = "/api/tasks?limit=12";
40:  function renderGuidance(r) {
77:          ${renderGuidance(r)}
85:      const res = await fetch(INSPECTOR_ENDPOINT, { cache: "no-store" });
88:      const selectedTaskId = window.selectedTaskId || null;
90:      render(selectedTaskId ? rows.filter((r) => String(r.task_id || r.id || "") === String(selectedTaskId)) : rows);
104:  window.addEventListener("execution-inspector:selected-task", () => tick());


## Dashboard task widget bridge markers
119:              <div data-task-row="true" data-task-id="${esc(t.id)}" style="display:flex;justify-content:space-between;gap:8px;cursor:pointer">
138:      ui.listEl.querySelectorAll("[data-task-row][data-task-id]").forEach((row) => {
140:          window.selectedTaskId = row.getAttribute("data-task-id");
141:          window.dispatchEvent(new CustomEvent("execution-inspector:selected-task", { detail: { taskId: window.selectedTaskId } }));
