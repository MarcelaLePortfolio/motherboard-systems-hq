#!/usr/bin/env python3
from pathlib import Path
import re

p = Path("/Users/marcela-dev/Projects/Motherboard_Systems_HQ/public/dashboard.html")
text = p.read_text(encoding="utf-8")

text = re.sub(
    r'(?ms)\s*<span class="text-xs uppercase tracking-wide text-gray-400">Consolidated</span>',
    '',
    text,
)
text = re.sub(
    r'(?ms)\s*<span class="text-xs uppercase tracking-wide text-indigo-300/80">Live</span>',
    '',
    text,
)
text = re.sub(
    r'(?ms)\s*<span class="text-xs uppercase tracking-wide text-teal-300/80">SSE</span>',
    '',
    text,
)

text = text.replace(
    '<h2 class="text-xl font-semibold mb-4 border-b border-gray-700 pb-2">Task History Over Time</h2>',
    '',
)
text = text.replace(
    '<section id="task-events-card" class="obs-surface">',
    '<section id="task-events-card" class="obs-surface phase61-events-fill">',
)

style_pattern = re.compile(r'(?ms)\s*<style id="phase61-layout-polish">.*?</style>\s*')
text = style_pattern.sub('\n', text, count=1)

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

      #operator-tabs,
      #observational-tabs {
        margin-bottom: 1.1rem;
      }

      #op-panel-chat,
      #op-panel-delegation,
      #obs-panel-recent,
      #obs-panel-activity,
      #obs-panel-events {
        padding-top: 0.1rem;
      }

      #matilda-chat-root {
        flex: 1 1 auto;
        display: flex;
        flex-direction: column;
        gap: 1rem;
      }

      #matilda-chat-transcript {
        min-height: 14rem;
        height: 14rem;
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

      #task-activity-card .h-64 {
        height: 100%;
        min-height: 18rem;
      }

      #task-events-card.phase61-events-fill {
        min-height: 100%;
        height: 100%;
      }

      #task-events-card.phase61-events-fill #mb-task-events-panel-anchor {
        flex: 1 1 auto;
        min-height: 18rem;
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
          min-height: 13rem;
          height: 13rem;
        }
      }
    </style>
'''
text = text.replace('</head>', f'{style_block}\n  </head>', 1)

p.write_text(text, encoding='utf-8')
print('phase61 tab cleanup pass applied')
