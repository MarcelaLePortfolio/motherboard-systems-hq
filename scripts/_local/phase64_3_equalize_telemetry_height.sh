#!/usr/bin/env bash
set -euo pipefail

python3 - << 'PY'
from pathlib import Path

path = Path("public/dashboard.html")
text = path.read_text()
original = text

css_block = """
    /* Phase 64.3 — equal-height workspace cards with internal telemetry scrolling */
    #phase61-workspace-grid {
      align-items: stretch;
    }

    #phase61-operator-column,
    #phase61-telemetry-column {
      min-height: 0;
      display: flex;
      flex-direction: column;
    }

    #operator-workspace-card,
    #observational-workspace-card {
      flex: 1 1 auto;
      height: 100%;
      min-height: 0;
      display: flex;
      flex-direction: column;
    }

    #operator-panels,
    #observational-panels {
      flex: 1 1 auto;
      min-height: 0;
      display: flex;
      flex-direction: column;
    }

    #op-panel-chat,
    #op-panel-delegation,
    #obs-panel-recent,
    #obs-panel-activity,
    #obs-panel-events {
      flex: 1 1 auto;
      min-height: 0;
    }

    #op-panel-chat.active,
    #op-panel-delegation.active,
    #obs-panel-recent.active,
    #obs-panel-activity.active,
    #obs-panel-events.active {
      display: flex;
      flex-direction: column;
      min-height: 0;
    }

    #recent-tasks-card,
    #task-activity-card,
    #task-events-card {
      flex: 1 1 auto;
      min-height: 0;
      overflow: hidden;
      display: flex;
      flex-direction: column;
    }

    #recent-tasks-card > [data-phase61-shell="recent"],
    #task-activity-card > [data-phase61-shell="history"] {
      flex: 1 1 auto;
      min-height: 0;
    }

    #recent-tasks-card [data-phase61-list="recent"],
    #task-activity-card [data-phase61-list="history"] {
      flex: 1 1 auto;
      min-height: 0;
      overflow-y: auto;
      padding-right: 4px;
    }

    #mb-task-events-panel-anchor,
    .phase61-events-fill {
      flex: 1 1 auto;
      min-height: 0;
      overflow: hidden;
    }

    @media (max-width: 1023px) {
      #phase61-operator-column,
      #phase61-telemetry-column,
      #operator-workspace-card,
      #observational-workspace-card {
        height: auto;
      }
    }
"""

anchor = """
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
"""

if css_block not in text:
    if anchor not in text:
        raise SystemExit("required CSS anchor not found in public/dashboard.html")
    text = text.replace(anchor, css_block + "\n" + anchor, 1)

if text == original:
    print("no changes needed")
else:
    path.write_text(text)
    print("patched public/dashboard.html")
PY
