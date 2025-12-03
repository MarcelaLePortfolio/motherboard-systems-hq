# Matilda Chat Layout – After Explicit 2-Column Refactor

Branch: feature/v11-dashboard-bundle

As of this refactor, the dashboard layout is:

- Main content is a 2-column Tailwind grid:
  - <main class="grid grid-cols-1 lg:grid-cols-2 gap-6">

Left column:
- Matilda Chat Console card
  - Root container: #matilda-chat-root
  - Content injected by: public/js/matilda-chat-console.js
- Project Visual Output card
  - Container: #project-output-card
  - Reserved for future visual artifacts (diagrams, previews, etc.)

Right column:
- Metrics row
  - Active Agents (#metric-agents)
  - Tasks Running (#metric-tasks)
  - Success Rate (#metric-success-rate)
  - Latency (#metric-latency)
- Task Delegation card
  - Container: #delegation-card
  - Textarea: #delegation-input
  - Submit button: #delegation-submit
  - Complete Task button: #complete-task-btn
  - Response display: #delegation-response
- Atlas Subsystem Status card
  - Container: #atlas-status-card
  - Status badge: #atlas-health
  - Details: #atlas-status-details
- System Reflections card
  - Container: #reflections-viewer-card
  - Logs: #recentLogs
- Critical Ops Alerts card
  - Container: #ops-alerts-card
  - List: #ops-alerts-list
- Task Activity Over Time card
  - Canvas: #task-activity-graph

Matilda Chat wiring:
- Script: public/js/matilda-chat-console.js
- Looks for #matilda-chat-root on DOMContentLoaded
- Renders:
  - #matilda-chat-transcript (scrollable)
  - #matilda-chat-input (textarea)
  - #matilda-chat-send (button)
- Sends POST /api/chat with JSON:
  { "message": "<user text>", "agent": "matilda" }
- Appends replies under the Matilda label in the transcript.

This note marks the stable post-refactor layout where:
- Matilda Chat and Project Visual Output occupy the left rail.
- Metrics, Task Delegation, Atlas, Reflections, Ops, and Task Activity occupy the right rail.
- No additional JS tries to rearrange grid structure; the split is controlled by index.html and Tailwind classes.
