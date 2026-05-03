#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

python3 <<'PY'
from pathlib import Path
import re

p = Path("public/dashboard.html")
text = p.read_text(encoding="utf-8")

text = re.sub(
    r'''(?ms)\n\s*<section aria-labelledby="subsystem-status-heading" class="space-y-4">\s*<h2 id="subsystem-status-heading" class="text-xs uppercase tracking-\[0\.24em\] text-gray-400">\s*Subsystem Status\s*</h2>\s*''',
    '\n      <section aria-label="Subsystem status" class="space-y-4">\n',
    text,
    count=1,
)

text = re.sub(
    r'(?ms)\s*<style id="phase61-layout-polish">.*?</style>\s*',
    '\n',
    text,
    count=1,
)

style_block = '''
    <style id="phase61-layout-polish">
      #phase61-workspace-grid {
        display: grid;
        grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
        gap: 1.5rem;
        align-items: stretch;
      }

      #phase61-operator-column,
      #phase61-telemetry-column {
        display: flex;
        flex-direction: column;
        min-width: 0;
      }

      #operator-workspace-card,
      #observational-workspace-card {
        display: flex;
        flex-direction: column;
        min-height: 36rem;
        height: 100%;
      }

      #operator-panels,
      #observational-panels {
        flex: 1 1 auto;
        display: flex;
        flex-direction: column;
      }

      #op-panel-chat,
      #op-panel-delegation,
      #obs-panel-recent,
      #obs-panel-activity,
      #obs-panel-events {
        height: 100%;
      }

      #op-panel-chat .obs-surface,
      #op-panel-delegation .obs-surface,
      #obs-panel-recent .obs-surface,
      #obs-panel-activity .obs-surface,
      #obs-panel-events .obs-surface {
        min-height: 100%;
      }

      #matilda-chat-card,
      #delegation-card,
      #recent-tasks-card,
      #task-activity-card,
      #task-events-card {
        display: flex;
        flex-direction: column;
      }

      #matilda-chat-root {
        flex: 1 1 auto;
        display: flex;
        flex-direction: column;
      }

      #matilda-chat-transcript {
        min-height: 15rem;
        height: 15rem;
      }

      #matilda-chat-root > .flex.space-x-3.items-end {
        margin-top: auto;
      }

      #delegation-card {
        justify-content: flex-start;
      }

      #delegation-input {
        min-height: 8rem;
      }

      #atlas-status-card {
        width: 100%;
      }

      @media (max-width: 1023px) {
        #phase61-workspace-grid {
          grid-template-columns: 1fr;
        }

        #operator-workspace-card,
        #observational-workspace-card {
          min-height: auto;
        }

        #matilda-chat-transcript {
          min-height: 14rem;
          height: 14rem;
        }
      }
    </style>
'''

text = text.replace('</head>', f'{style_block}\n  </head>', 1)

p.write_text(text, encoding='utf-8')
print('phase61 final touchups applied')
PY
