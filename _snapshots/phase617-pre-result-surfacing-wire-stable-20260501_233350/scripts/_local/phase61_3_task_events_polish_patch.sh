#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

TARGET_HTML="public/dashboard.html"

if [[ ! -f "$TARGET_HTML" ]]; then
  echo "ERROR: missing $TARGET_HTML" >&2
  exit 1
fi

if [[ ! -x scripts/verify-dashboard-layout-contract.sh ]]; then
  echo "ERROR: missing executable verifier scripts/verify-dashboard-layout-contract.sh" >&2
  exit 1
fi

scripts/verify-dashboard-layout-contract.sh "$TARGET_HTML"

cp "$TARGET_HTML" "${TARGET_HTML}.bak.phase61_3"

python3 - << 'PY'
from pathlib import Path
import re
import sys

path = Path("public/dashboard.html")
html = path.read_text()

required_markers = [
    "Task Events",
    "Telemetry Workspace",
    "Atlas Subsystem Status",
]
for marker in required_markers:
    if marker not in html:
        raise SystemExit(f"required marker not found: {marker}")

style_block = """
  <style id="phase61-task-events-polish">
    .task-events-panel,
    [data-phase61-task-events],
    [data-tab-panel="task-events"],
    #task-events-panel,
    #task-events,
    .task-events {
      min-height: 360px;
    }

    .task-events-panel .task-events-list,
    [data-phase61-task-events] .task-events-list,
    [data-tab-panel="task-events"] .task-events-list,
    #task-events-panel .task-events-list,
    #task-events .task-events-list,
    .task-events .task-events-list,
    .task-events-panel ul,
    [data-phase61-task-events] ul,
    [data-tab-panel="task-events"] ul,
    #task-events-panel ul,
    #task-events ul,
    .task-events ul {
      max-height: 420px;
      overflow: auto;
      padding-right: 6px;
      overscroll-behavior: contain;
      scroll-behavior: smooth;
    }

    .task-events-panel .task-event,
    [data-phase61-task-events] .task-event,
    [data-tab-panel="task-events"] .task-event,
    #task-events-panel .task-event,
    #task-events .task-event,
    .task-events .task-event,
    .task-events-panel li,
    [data-phase61-task-events] li,
    [data-tab-panel="task-events"] li,
    #task-events-panel li,
    #task-events li,
    .task-events li {
      position: relative;
      display: grid;
      grid-template-columns: minmax(96px, 120px) minmax(120px, 160px) 1fr;
      gap: 10px;
      align-items: start;
      padding: 10px 12px 10px 14px;
      margin-bottom: 8px;
      border-radius: 10px;
      background: rgba(255,255,255,0.03);
      border: 1px solid rgba(255,255,255,0.08);
      line-height: 1.35;
      font-size: 12px;
    }

    .task-events-panel .task-event::before,
    [data-phase61-task-events] .task-event::before,
    [data-tab-panel="task-events"] .task-event::before,
    #task-events-panel .task-event::before,
    #task-events .task-event::before,
    .task-events .task-event::before,
    .task-events-panel li::before,
    [data-phase61-task-events] li::before,
    [data-tab-panel="task-events"] li::before,
    #task-events-panel li::before,
    #task-events li::before,
    .task-events li::before {
      content: "";
      position: absolute;
      left: 0;
      top: 10px;
      bottom: 10px;
      width: 3px;
      border-radius: 999px;
      background: rgba(255,255,255,0.18);
    }

    .task-events-panel .task-event.phase61-event-terminal::before,
    [data-phase61-task-events] .task-event.phase61-event-terminal::before,
    [data-tab-panel="task-events"] .task-event.phase61-event-terminal::before,
    #task-events-panel .task-event.phase61-event-terminal::before,
    #task-events .task-event.phase61-event-terminal::before,
    .task-events .task-event.phase61-event-terminal::before,
    .task-events-panel li.phase61-event-terminal::before,
    [data-phase61-task-events] li.phase61-event-terminal::before,
    [data-tab-panel="task-events"] li.phase61-event-terminal::before,
    #task-events-panel li.phase61-event-terminal::before,
    #task-events li.phase61-event-terminal::before,
    .task-events li.phase61-event-terminal::before {
      background: rgba(244, 114, 182, 0.95);
    }

    .task-events-panel .task-event.phase61-event-active::before,
    [data-phase61-task-events] .task-event.phase61-event-active::before,
    [data-tab-panel="task-events"] .task-event.phase61-event-active::before,
    #task-events-panel .task-event.phase61-event-active::before,
    #task-events .task-event.phase61-event-active::before,
    .task-events .task-event.phase61-event-active::before,
    .task-events-panel li.phase61-event-active::before,
    [data-phase61-task-events] li.phase61-event-active::before,
    [data-tab-panel="task-events"] li.phase61-event-active::before,
    #task-events-panel li.phase61-event-active::before,
    #task-events li.phase61-event-active::before,
    .task-events li.phase61-event-active::before {
      background: rgba(34, 197, 94, 0.95);
    }

    .task-events-panel .task-event.phase61-event-waiting::before,
    [data-phase61-task-events] .task-event.phase61-event-waiting::before,
    [data-tab-panel="task-events"] .task-event.phase61-event-waiting::before,
    #task-events-panel .task-event.phase61-event-waiting::before,
    #task-events .task-event.phase61-event-waiting::before,
    .task-events .task-event.phase61-event-waiting::before,
    .task-events-panel li.phase61-event-waiting::before,
    [data-phase61-task-events] li.phase61-event-waiting::before,
    [data-tab-panel="task-events"] li.phase61-event-waiting::before,
    #task-events-panel li.phase61-event-waiting::before,
    #task-events li.phase61-event-waiting::before,
    .task-events li.phase61-event-waiting::before {
      background: rgba(250, 204, 21, 0.95);
    }

    .phase61-task-event-time {
      font-variant-numeric: tabular-nums;
      color: rgba(255,255,255,0.68);
      white-space: nowrap;
    }

    .phase61-task-event-kind {
      font-weight: 600;
      letter-spacing: 0.01em;
      color: rgba(255,255,255,0.92);
      word-break: break-word;
    }

    .phase61-task-event-detail {
      color: rgba(255,255,255,0.78);
      word-break: break-word;
    }

    .phase61-task-event-empty {
      padding: 12px 2px 2px;
      color: rgba(255,255,255,0.62);
      font-size: 12px;
    }

    @media (max-width: 920px) {
      .task-events-panel .task-event,
      [data-phase61-task-events] .task-event,
      [data-tab-panel="task-events"] .task-event,
      #task-events-panel .task-event,
      #task-events .task-event,
      .task-events .task-event,
      .task-events-panel li,
      [data-phase61-task-events] li,
      [data-tab-panel="task-events"] li,
      #task-events-panel li,
      #task-events li,
      .task-events li {
        grid-template-columns: 1fr;
        gap: 4px;
      }
    }
  </style>
""".strip("\n")

script_block = """
  <script id="phase61-task-events-polish-script">
    (() => {
      const SELECTORS = [
        '[data-tab-panel="task-events"]',
        '[data-phase61-task-events]',
        '#task-events-panel',
        '#task-events',
        '.task-events-panel',
        '.task-events'
      ];

      const EVENT_ACTIVE = /run|start|resume|lease|dispatch|ack|progress|active|heartbeat/i;
      const EVENT_WAITING = /queue|queued|pending|wait|retry|hold|sleep/i;
      const EVENT_TERMINAL = /complete|completed|success|failed|error|cancel|cancelled|timeout|terminal/i;

      const findPanel = () => {
        for (const selector of SELECTORS) {
          const node = document.querySelector(selector);
          if (node) return node;
        }
        return null;
      };

      const classify = (text) => {
        if (EVENT_TERMINAL.test(text)) return 'phase61-event-terminal';
        if (EVENT_WAITING.test(text)) return 'phase61-event-waiting';
        if (EVENT_ACTIVE.test(text)) return 'phase61-event-active';
        return '';
      };

      const normalizeRow = (row) => {
        if (row.dataset.phase61Polished === '1') return;
        row.dataset.phase61Polished = '1';
        row.classList.add('task-event');

        const raw = (row.innerText || row.textContent || '').replace(/\\s+/g, ' ').trim();
        const parts = raw.split(/\\s+[|·•]\\s+|\\s{2,}/).filter(Boolean);

        const timeMatch = raw.match(/\\b\\d{1,2}:\\d{2}(?::\\d{2})?(?:\\.\\d+)?(?:\\s?[AP]M)?\\b|\\b\\d{4}-\\d{2}-\\d{2}[T ]\\d{2}:\\d{2}(?::\\d{2})?(?:\\.\\d+)?Z?\\b/i);
        const timeText = timeMatch ? timeMatch[0] : (parts[0] || '');
        const remaining = parts.filter((part, index) => !(index === 0 && part === timeText));
        const kindText = remaining[0] || 'event';
        const detailText = remaining.slice(1).join(' • ') || raw;

        row.classList.add(classify(`${kindText} ${detailText}`));

        row.innerHTML = `
          <div class="phase61-task-event-time">${timeText || '—'}</div>
          <div class="phase61-task-event-kind">${kindText}</div>
          <div class="phase61-task-event-detail">${detailText}</div>
        `;
      };

      const polish = () => {
        const panel = findPanel();
        if (!panel) return;

        panel.setAttribute('data-phase61-task-events', 'true');

        const rows = panel.querySelectorAll('li, .task-event, [data-task-event-row]');
        rows.forEach(normalizeRow);

        if (!rows.length && !panel.querySelector('.phase61-task-event-empty')) {
          const empty = document.createElement('div');
          empty.className = 'phase61-task-event-empty';
          empty.textContent = 'No task events yet.';
          panel.appendChild(empty);
        }
      };

      const boot = () => {
        polish();
        const panel = findPanel();
        if (!panel) return;

        const observer = new MutationObserver(() => polish());
        observer.observe(panel, { childList: true, subtree: true, characterData: true });
      };

      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', boot, { once: true });
      } else {
        boot();
      }
    })();
  </script>
""".strip("\n")

if 'id="phase61-task-events-polish"' not in html:
    if "</head>" in html:
        html = html.replace("</head>", style_block + "\n</head>", 1)
    else:
        raise SystemExit("could not find </head> to inject Phase 61.3 style block")

if 'id="phase61-task-events-polish-script"' not in html:
    if "</body>" in html:
        html = html.replace("</body>", script_block + "\n</body>", 1)
    else:
        raise SystemExit("could not find </body> to inject Phase 61.3 script block")

path.write_text(html)
PY

scripts/verify-dashboard-layout-contract.sh "$TARGET_HTML"

echo "Phase 61.3 task events polish patch applied safely."
echo "Backup saved to ${TARGET_HTML}.bak.phase61_3"
echo "Next:"
echo "  scripts/_local/phase61_safe_dashboard_cycle.sh"
