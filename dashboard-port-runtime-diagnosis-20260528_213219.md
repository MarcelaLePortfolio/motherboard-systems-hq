# Dashboard Port Runtime Diagnosis

Repo: /Users/marcela-dev/Projects/motherboard-systems-hq-clean
Branch: feature/backup-system-v2
HEAD: 0b61d5ea1be8104bf425d357207acada5c1d1ae0

## Docker Compose Status

NAME                                       IMAGE                                    COMMAND                  SERVICE     CREATED        STATUS        PORTS
motherboard-systems-hq-clean-dashboard-1   motherboard-systems-hq-clean-dashboard   "docker-entrypoint.s…"   dashboard   3 hours ago    Up 3 hours    0.0.0.0:8080->3000/tcp, [::]:8080->3000/tcp
motherboard-systems-hq-clean-postgres-1    postgres:16-alpine                       "docker-entrypoint.s…"   postgres    20 hours ago   Up 20 hours   0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp

## Dashboard Container Ports

0.0.0.0:8080

## Host Curl Probes

### http://localhost:3000

### http://localhost:3000/api/tasks

### http://localhost:3001

### http://localhost:3001/api/tasks

### http://localhost:5173

### http://localhost:8080
HTTP/1.1 200 OK
X-Powered-By: Express
Accept-Ranges: bytes
Cache-Control: public, max-age=0
Last-Modified: Thu, 28 May 2026 18:53:12 GMT
ETag: W/"b5c5-19e6feef5c0"
Content-Type: text/html; charset=utf-8
Content-Length: 46533
Date: Fri, 29 May 2026 04:32:19 GMT
Connection: keep-alive
Keep-Alive: timeout=5

<!DOCTYPE html>
<html lang="en">
<head>
  <meta http-equiv="Cache-Control" content="no-store, no-cache, must-revalidate, max-age=0" />
  <meta http-equiv="Pragma" content="no-cache" />
  <meta http-equiv="Expires" content="0" />
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Motherboard Systems Operator Console</title>

  <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet" />
  <link rel="stylesheet" href="css/broadcast.css" />
  <link rel="stylesheet" href="css/dashboard.css?v=darkmode" />
  <link rel="stylesheet" href="css/dashboard-reflections.css" />
  <link rel="stylesheet" href="css/agent-status-row.css" />
  <link rel="stylesheet" href="css/matilda-chat.css" />
  <link rel="stylesheet" href="css/demo_layout_trim.css" />
  <link rel="stylesheet" href="css/phase59_demo_focus.css" />
  <link rel="stylesheet" href="css/phase60_live_polish.css" />
  <link rel="stylesheet" href="css/phase61_workspace_consolidation.css" />
  <link rel="stylesheet" href="css/phase61_tabs_observational_workspace.css" />

  <style id="matilda-chat-typography-polish">
    #matilda-chat-transcript p {
      line-height: 1.4 !important;
      margin-bottom: 0.5rem !important;
    }
    #matilda-chat-transcript .user-message {

## Dashboard Logs Tail

dashboard-1  |   originalUrl: '/api/tasks?limit=50',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:8080/?v=task-card-fallbacks-663d043c',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [HTTP] GET /api/tasks?limit=50
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=50',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:8080/?v=task-card-fallbacks-663d043c',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [HTTP] GET /api/tasks?limit=12
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=12',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:8080/?v=task-card-fallbacks-663d043c',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [HTTP] GET /api/guidance-history
dashboard-1  | [HTTP] GET /api/tasks?limit=50
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=50',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:8080/?v=task-card-fallbacks-663d043c',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [HTTP] GET /api/agent-status
dashboard-1  | [HTTP] GET /api/tasks?limit=50
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=50',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:8080/?v=task-card-fallbacks-663d043c',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [HTTP] GET /api/tasks?limit=12
dashboard-1  | [HTTP] GET /api/guidance-history
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=12',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:8080/?v=task-card-fallbacks-663d043c',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [HTTP] GET /api/tasks?limit=50
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=50',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:8080/?v=task-card-fallbacks-663d043c',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [HTTP] GET /api/tasks?limit=50
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=50',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:8080/?v=task-card-fallbacks-663d043c',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [HTTP] GET /api/agent-status
dashboard-1  | [HTTP] GET /api/tasks?limit=12
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=12',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:8080/?v=task-card-fallbacks-663d043c',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [HTTP] GET /api/guidance-history
dashboard-1  | [HTTP] GET /api/tasks?limit=50
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=50',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:8080/?v=task-card-fallbacks-663d043c',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [HTTP] GET /api/tasks?limit=50
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=50',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:8080/?v=task-card-fallbacks-663d043c',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [HTTP] GET /api/tasks?limit=12
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=12',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:8080/?v=task-card-fallbacks-663d043c',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [HTTP] GET /api/guidance-history
dashboard-1  | [HTTP] GET /api/tasks?limit=50
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=50',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:8080/?v=task-card-fallbacks-663d043c',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [HTTP] GET /api/agent-status
dashboard-1  | [HTTP] GET /api/tasks?limit=50
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=50',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:8080/?v=task-card-fallbacks-663d043c',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [HTTP] GET /api/tasks?limit=12
dashboard-1  | [HTTP] GET /api/guidance-history
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=12',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:8080/?v=task-card-fallbacks-663d043c',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [HTTP] GET /api/tasks?limit=50
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=50',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:8080/?v=task-card-fallbacks-663d043c',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [HTTP] GET /api/tasks?limit=50
dashboard-1  | [phase57c-router] /api/tasks probe {
dashboard-1  |   originalUrl: '/api/tasks?limit=50',
dashboard-1  |   baseUrl: '/api/tasks',
dashboard-1  |   path: '/',
dashboard-1  |   referer: 'http://localhost:8080/?v=task-card-fallbacks-663d043c',
dashboard-1  |   userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',
dashboard-1  |   accept: '*/*'
dashboard-1  | }
dashboard-1  | [HTTP] GET /

## Compose File Port References

docker-compose.override.yml:6:    ports:
docker-compose.override.yml:7:      - "8080:3000"
docker-compose.yml:8:    ports:
docker-compose.yml:34:    ports:
docker-compose.yml:35:      - "8080:3000"
