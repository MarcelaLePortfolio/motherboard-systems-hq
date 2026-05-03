# Phase 487 Log Readability Contract Audit

Generated: Tue Apr 21 11:33:41 PDT 2026

## Runtime posture

```
?? docs/phase487_log_readability_contract_audit.md

NAME                                 IMAGE                              COMMAND                  SERVICE     CREATED          STATUS                        PORTS
motherboard_systems_hq-dashboard-1   motherboard_systems_hq-dashboard   "docker-entrypoint.s…"   dashboard   2 minutes ago    Up About a minute (healthy)   0.0.0.0:8080->3000/tcp, [::]:8080->3000/tcp
motherboard_systems_hq-postgres-1    postgres:16-alpine                 "docker-entrypoint.s…"   postgres    29 minutes ago   Up 29 minutes                 0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp
```

## Live surface checks

```
GET /api/logs
HTTP/1.1 404 Not Found
X-Powered-By: Express
Content-Security-Policy: default-src 'none'
X-Content-Type-Options: nosniff
Content-Type: text/html; charset=utf-8
Content-Length: 147
Date: Tue, 21 Apr 2026 18:33:41 GMT
Connection: keep-alive
Keep-Alive: timeout=5

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Error</title>
</head>
<body>
<pre>Cannot GET /api/logs</pre>
</body>
</html>

GET /logs
HTTP/1.1 404 Not Found
X-Powered-By: Express
Content-Security-Policy: default-src 'none'
X-Content-Type-Options: nosniff
Content-Type: text/html; charset=utf-8
Content-Length: 143
Date: Tue, 21 Apr 2026 18:33:41 GMT
Connection: keep-alive
Keep-Alive: timeout=5

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Error</title>
</head>
<body>
<pre>Cannot GET /logs</pre>
</body>
</html>

GET /api/tasks
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: application/json; charset=utf-8
Content-Length: 204
ETag: W/"cc-gAxittQuF0YcWrOzU8IcNFeRzlE"
Date: Tue, 21 Apr 2026 18:33:41 GMT
Connection: keep-alive
Keep-Alive: timeout=5

{"ok":true,"tasks":[{"id":"1","task_id":"task.a3e77f01-bb39-4a4d-95c6-28b2a673aec0","title":"Phase 487 delegation surface verification request","status":"queued","updated_at":"2026-04-21T18:29:11.321Z"}]}```

## Served UI references

```
public/dashboard.html:133:                      <div id="operator-guidance-panel" class="mt-4 rounded-xl border border-gray-700 bg-gray-900/70 p-4 min-h-[140px]">
public/dashboard.html:135:                        <div id="operator-guidance-response" class="text-sm text-gray-300 leading-6">
public/dashboard.html:139:                        <div id="operator-guidance-meta" class="mt-3 text-xs text-gray-500 leading-5">
public/dashboard.html:192:                    <div id="tasks-widget"></div>
public/dashboard.html:275:    var el = document.getElementById("operator-guidance-meta");
public/dashboard.html:287:<script id="phase487-operator-guidance-fallback">
public/dashboard.html:300:    const response = document.getElementById("operator-guidance-response");
public/dashboard.html:301:    const meta = document.getElementById("operator-guidance-meta");
public/dashboard.html:504:        (Array.isArray(data.logs) && data.logs.length > 0) ||
public/dashboard.html:760:    const meta = document.getElementById("operator-guidance-meta");
public/index.html:161:    #operator-guidance-panel,
public/index.html:316:                    <div id="operator-guidance-panel" class="mt-3 rounded-xl border border-gray-700 bg-gray-900/70 p-4">
public/index.html:318:                      <div id="operator-guidance-response" class="text-sm text-gray-300 leading-6">
public/index.html:322:                      <div id="operator-guidance-meta" class="mt-3 text-xs text-gray-500 leading-5">
public/index.html:734:        (Array.isArray(data.logs) && data.logs.length > 0) ||
public/index.html:1008:<script id="phase487-operator-guidance-fallback">
public/index.html:1021:    const response = document.getElementById("operator-guidance-response");
public/index.html:1022:    const meta = document.getElementById("operator-guidance-meta");
public/index.html:1196:  #operator-guidance-panel,
```

## Backend route ownership

```
server.mjs:188:app.use("/api/tasks", apiTasksRouter);
server.mjs:354:app.get("/api/tasks", async (req, res) => {
server.mjs:439:app.get("/events/tasks", async (req, res) => {
```

## Likely diagnosis

- If /api/logs and /logs both 404, log readability is currently a missing surface, not just bad formatting.
- If /api/tasks is live but logs are absent, task clarity can still be improved via task title/summary rendering without backend mutation.
- Safe next corridor after this audit: UI-only task clarity/readability improvement using existing /api/tasks data.
