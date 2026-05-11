
from pathlib import Path

path = Path("public/index.html")

text = path.read_text()

old_tab = '''              <button id="obs-tab-events" class="obs-tab" type="button" data-workspace-tab data-target="obs-panel-events" role="tab" aria-selected="false" aria-controls="obs-panel-events">

                Execution Inspector

              </button>'''

old_panel = '''              <div id="obs-panel-events" class="obs-panel" data-workspace-panel role="tabpanel" aria-labelledby="obs-tab-events" hidden>

                <section id="task-events-card" class="obs-surface">

                  <div id="mb-task-events-panel-anchor" class="bg-gray-900 border border-gray-700 rounded-xl p-3 text-sm text-gray-300"></div>

                </section>

              </div>'''

if old_tab not in text:

    raise SystemExit("Execution Inspector tab block not found")

if old_panel not in text:

    raise SystemExit("Execution Inspector panel block not found")

text = text.replace(old_tab, "", 1)

text = text.replace(old_panel, "", 1)

path.write_text(text)

print("Execution Inspector tab and panel removed; Telemetry Console shell preserved.")

