#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

python3 <<'PY'
from pathlib import Path
import re

p = Path("public/dashboard.html")
text = p.read_text(encoding="utf-8")

text = re.sub(
    r'''(?ms)^\s*<section id="phase61-workspace-shell" aria-labelledby="phase61-workspace-heading" class="space-y-4">\s*<div class="flex items-center justify-between">\s*<h2 id="phase61-workspace-heading" class="text-xs uppercase tracking-\[0\.24em\] text-gray-400">\s*Operator Workspace\s*</h2>\s*</div>\s*<div id="phase61-workspace-grid">''',
    '''      <section id="phase61-workspace-shell" class="space-y-4">
        <div id="phase61-workspace-grid">''',
    text,
    count=1,
)

text = text.replace(
    'id="phase61-operator-column" class="space-y-4" aria-label="Operator workspace"',
    'id="phase61-operator-column" class="space-y-4" aria-label="Operator workspace"',
    1,
)

text = text.replace(
    'id="phase61-telemetry-column" class="space-y-4" aria-label="Observational workspace"',
    'id="phase61-telemetry-column" class="space-y-4" aria-label="Observational workspace"',
    1,
)

text = text.replace(
    '<section id="phase61-workspace-shell" aria-label="Workspace region" class="space-y-4">',
    '<section id="phase61-workspace-shell" class="space-y-4">',
)

text = text.replace(
    '                              <section id="phase61-operator-column"',
    '          <section id="phase61-operator-column"',
)

text = text.replace(
    '\n  <section aria-labelledby="subsystem-status-heading" class="space-y-4">',
    '\n      <section aria-labelledby="subsystem-status-heading" class="space-y-4">',
)

style_pattern = re.compile(r'(?ms)\s*<style id="phase61-layout-polish">.*?</style>\s*')
text = style_pattern.sub('', text)

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

      #matilda-chat-transcript {
        min-height: 18rem;
      }

      #delegation-card {
        display: flex;
        flex-direction: column;
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
      }
    </style>
'''

text = text.replace('</head>', f'{style_block}\n  </head>', 1)

p.write_text(text, encoding='utf-8')
print('phase61 layout finalized')
PY
