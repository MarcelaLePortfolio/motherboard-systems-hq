#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

python3 <<'PY'
from pathlib import Path
import re
import sys

p = Path("public/dashboard.html")
text = p.read_text(encoding="utf-8")

main_start = '<main class="phase59-shell space-y-6">'
compat_start = '    <div id="phase59-compat-roots" hidden aria-hidden="true">'
if main_start not in text or compat_start not in text:
    sys.exit("required dashboard anchors not found")

head_start = '<head>'
head_end = '</head>'
if head_start not in text or head_end not in text:
    sys.exit("head anchors not found")

main_idx = text.index(main_start)
compat_idx = text.index(compat_start)

prefix = text[:main_idx]
suffix = text[compat_idx:]

# Remove all ad-hoc inline phase61/atlas/matilda/task-events style injections from head.
head_open_idx = prefix.index(head_start) + len(head_start)
head_close_idx = prefix.index(head_end)
head_inner = prefix[head_open_idx:head_close_idx]

patterns = [
    r'\n\s*<style id="phase61-layout-polish">.*?</style>',
    r'\n\s*<style>\s*#task-events-card\s*\{.*?</style>',
    r'\n\s*<style>\s*#matilda-chat-root\s*\{.*?</style>',
    r'\n\s*<style>\s*#atlas-status-card\s*\{.*?</style>',
]
for pattern in patterns:
    head_inner = re.sub(pattern, '\n', head_inner, flags=re.S)

clean_prefix = prefix[:head_open_idx] + head_inner + prefix[head_close_idx:]

style_block = """
    <style id="phase61-layout-polish">
      #phase61-workspace-grid {
        display: grid;
        grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
        gap: 1.5rem;
        align-items: start;
      }

      #phase61-operator-column,
      #phase61-telemetry-column {
        min-width: 0;
      }

      #operator-workspace-card,
      #observational-workspace-card {
        min-height: 28rem;
      }

      #operator-tabs,
      #observational-tabs {
        margin-bottom: 1rem;
      }

      #operator-panels,
      #observational-panels {
        min-width: 0;
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
        display: flex;
        flex-direction: column;
        gap: 1rem;
      }

      #matilda-chat-transcript {
        min-height: 16rem;
        height: 16rem;
      }

      #matilda-helper-text-ops {
        margin-top: auto;
        opacity: 0.78;
      }

      #delegation-input {
        min-height: 8rem;
      }

      #task-events-card #mb-task-events-panel-anchor {
        min-height: 18rem;
      }

      #atlas-status-section {
        width: 100%;
      }

      #atlas-status-card {
        width: 100%;
        max-width: 100%;
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
"""

clean_prefix = clean_prefix.replace("</head>", f"{style_block}\n  </head>", 1)

main_block = """<main class="phase59-shell space-y-6">
      <section
        id="metrics-row"
        class="grid grid-cols-2 xl:grid-cols-4 gap-4"
        aria-label="System metrics"
      >
        <div class="bg-gray-800 p-4 rounded-2xl shadow-lg border border-gray-700">
          <p class="text-sm text-gray-400">Active Agents</p>
          <p id="metric-agents" class="text-2xl font-bold text-blue-400">--</p>
        </div>
        <div class="bg-gray-800 p-4 rounded-2xl shadow-lg border border-gray-700">
          <p class="text-sm text-gray-400">Tasks Running</p>
          <p id="metric-tasks" class="text-2xl font-bold text-yellow-400">--</p>
        </div>
        <div class="bg-gray-800 p-4 rounded-2xl shadow-lg border border-gray-700">
          <p class="text-sm text-gray-400">Success Rate</p>
          <p id="metric-success-rate" class="text-2xl font-bold text-green-400">--</p>
        </div>
        <div class="bg-gray-800 p-4 rounded-2xl shadow-lg border border-gray-700">
          <p class="text-sm text-gray-400">Latency (ms)</p>
          <p id="metric-latency" class="text-2xl font-bold text-red-400">--</p>
        </div>
      </section>

      <section id="phase61-workspace-shell" class="space-y-4">
        <div id="phase61-workspace-grid">
          <section id="phase61-operator-column" class="space-y-4" aria-label="Operator workspace">
            <section id="operator-workspace-card" class="bg-gray-800 p-6 rounded-2xl shadow-lg border border-gray-700" data-workspace-root>
              <div class="flex items-center justify-between mb-4 border-b border-gray-700 pb-3">
                <h2 class="text-xl font-semibold">Operator Workspace</h2>
              </div>

              <div id="operator-tabs" role="tablist" aria-label="Operator workspace tabs">
                <button id="op-tab-chat" class="obs-tab active" type="button" data-workspace-tab data-target="op-panel-chat" role="tab" aria-selected="true" aria-controls="op-panel-chat">
                  Chat
                </button>
                <button id="op-tab-delegation" class="obs-tab" type="button" data-workspace-tab data-target="op-panel-delegation" role="tab" aria-selected="false" aria-controls="op-panel-delegation">
                  Delegation
                </button>
              </div>

              <div id="operator-panels">
                <div id="op-panel-chat" class="obs-panel active" data-workspace-panel role="tabpanel" aria-labelledby="op-tab-chat">
                  <section id="matilda-chat-card" class="obs-surface">
                    <div id="matilda-chat-root">
                      <div id="matilda-chat-transcript" class="bg-gray-900 border border-gray-700 rounded-xl p-3 overflow-y-auto text-sm">
                        <p class="text-gray-500 italic">Chat with Matilda about tasks, status, or next steps...</p>
                      </div>
                      <div class="flex space-x-3 items-end">
                        <textarea id="matilda-chat-input" rows="3" class="flex-1 bg-gray-900 border border-gray-700 rounded-xl p-3 text-sm resize-none focus:ring-2 focus:ring-purple-500 focus:border-purple-500" placeholder="Type a message to Matilda and press Enter or click Send..."></textarea>
                        <button id="matilda-chat-send" class="px-5 py-2 rounded-xl font-semibold text-sm bg-purple-500 hover:bg-purple-600 focus:outline-none focus:ring-2 focus:ring-purple-400 transition transform hover:-translate-y-0.5 shadow-lg">Send</button>
                        <button id="matilda-chat-quick-check" class="px-3 py-2 rounded-xl font-semibold text-xs bg-gray-700 hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-purple-400 transition shadow-lg">Quick check</button>
                      </div>
                      <p id="matilda-helper-text-ops" class="text-xs text-gray-400">Matilda is currently using a placeholder /api/chat stub (Phase 11.3 baseline).</p>
                    </div>
                  </section>
                </div>

                <div id="op-panel-delegation" class="obs-panel" data-workspace-panel role="tabpanel" aria-labelledby="op-tab-delegation" hidden>
                  <section id="delegation-card" class="obs-surface space-y-4">
                    <textarea id="delegation-input" rows="4" class="w-full bg-gray-900 border border-gray-700 p-3 rounded-xl focus:ring-teal-500 focus:border-teal-500 resize-none text-white placeholder-gray-500" placeholder="Delegate a new task or modify system parameters..."></textarea>
                    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-3">
                      <button id="delegation-submit" class="w-full md:w-auto bg-teal-600 hover:bg-teal-700 text-white font-bold py-2 px-4 rounded-xl transition duration-200">Submit Delegation</button>
                      <button id="complete-task-btn" class="w-full md:w-auto bg-blue-500 hover:bg-blue-600 text-white font-semibold py-2 px-4 rounded-xl transition duration-200">Complete Task (Alpha)</button>
                    </div>
                    <div id="delegation-response" class="mt-2 text-sm text-gray-300 italic"></div>
                  </section>
                </div>
              </div>
            </section>
          </section>

          <section id="phase61-telemetry-column" class="space-y-4" aria-label="Telemetry workspace">
            <section id="observational-workspace-card" class="bg-gray-800 p-6 rounded-2xl shadow-lg border border-gray-700" data-workspace-root>
              <div class="flex items-center justify-between mb-4 border-b border-gray-700 pb-3">
                <h2 class="text-xl font-semibold">Telemetry Workspace</h2>
              </div>

              <div id="observational-tabs" role="tablist" aria-label="Telemetry workspace tabs">
                <button id="obs-tab-recent" class="obs-tab active" type="button" data-workspace-tab data-target="obs-panel-recent" role="tab" aria-selected="true" aria-controls="obs-panel-recent">
                  Recent Tasks
                </button>
                <button id="obs-tab-activity" class="obs-tab" type="button" data-workspace-tab data-target="obs-panel-activity" role="tab" aria-selected="false" aria-controls="obs-panel-activity">
                  Task History
                </button>
                <button id="obs-tab-events" class="obs-tab" type="button" data-workspace-tab data-target="obs-panel-events" role="tab" aria-selected="false" aria-controls="obs-panel-events">
                  Task Events
                </button>
              </div>

              <div id="observational-panels">
                <div id="obs-panel-recent" class="obs-panel active" data-workspace-panel role="tabpanel" aria-labelledby="obs-tab-recent">
                  <section id="recent-tasks-card" class="obs-surface">
                    <div id="tasks-widget"></div>
                  </section>
                </div>

                <div id="obs-panel-activity" class="obs-panel" data-workspace-panel role="tabpanel" aria-labelledby="obs-tab-activity" hidden>
                  <section id="task-activity-card" class="obs-surface">
                    <div class="h-64">
                      <canvas id="task-activity-graph" class="w-full h-full"></canvas>
                    </div>
                  </section>
                </div>

                <div id="obs-panel-events" class="obs-panel" data-workspace-panel role="tabpanel" aria-labelledby="obs-tab-events" hidden>
                  <section id="task-events-card" class="obs-surface">
                    <div id="mb-task-events-panel-anchor"></div>
                  </section>
                </div>
              </div>
            </section>
          </section>
        </div>
      </section>

      <section id="atlas-status-section" aria-label="Subsystem status" class="space-y-4">
        <section id="atlas-status-card" class="bg-gray-800 p-6 rounded-2xl shadow-lg border border-gray-700">
          <h2 class="text-xl font-semibold mb-4 border-b border-gray-700 pb-3 flex justify-between items-center">
            Atlas Subsystem Status
            <span id="atlas-health" class="text-xs font-medium px-2 py-1 rounded-full bg-orange-500 text-white">
              Degraded
            </span>
          </h2>
          <div id="atlas-status-details" class="space-y-2 text-gray-300">
            <p>
              Core Engine:
              <span class="text-yellow-400">Initializing...</span>
            </p>
          </div>
        </section>
      </section>
    </main>
"""

p.write_text(clean_prefix + main_block + suffix, encoding="utf-8")
print("phase61 layout fully repaired")
PY

cat > scripts/verify-dashboard-two-panel.sh <<'VERIFY'
#!/usr/bin/env bash
set -euo pipefail

URL="${1:-http://127.0.0.1:8080/dashboard}"
TMP_HTML="$(mktemp)"
TMP_HEADERS="$(mktemp)"
trap 'rm -f "$TMP_HTML" "$TMP_HEADERS"' EXIT

curl -fsS -D "$TMP_HEADERS" "$URL" -o "$TMP_HTML"

echo "🔎 Verifying dashboard layout at: $URL"

required_markers=(
  'Operator Workspace'
  'Chat'
  'Delegation'
  'Telemetry Workspace'
  'Recent Tasks'
  'Task History'
  'Task Events'
  'Atlas Subsystem Status'
)

missing=0
for marker in "${required_markers[@]}"; do
  if grep -Fq "$marker" "$TMP_HTML"; then
    echo "✅ Found: $marker"
  else
    echo "❌ Missing marker: $marker"
    missing=1
  fi
done

echo
echo "ℹ️ HTTP headers:"
sed -n '1,20p' "$TMP_HEADERS"

echo
if [ "$missing" -eq 0 ]; then
  echo "✅ Layout contract PASSED."
else
  echo "🧯 Layout contract FAILED."
  exit 1
fi
VERIFY

chmod +x scripts/_local/repair_phase61_layout_now.sh scripts/verify-dashboard-two-panel.sh
