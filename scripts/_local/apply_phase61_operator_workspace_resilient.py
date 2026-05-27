#!/usr/bin/env python3
from pathlib import Path
import sys

dashboard = Path("public/dashboard.html")
tabs_js = Path("public/js/phase61_tabs_workspace.js")

text = dashboard.read_text(encoding="utf-8")

operator_token = 'id="phase61-operator-column"'
telemetry_token = 'id="phase61-telemetry-column"'

op_idx = text.find(operator_token)
tel_idx = text.find(telemetry_token)

print(f"operator_token_found={op_idx != -1}")
print(f"telemetry_token_found={tel_idx != -1}")

if op_idx == -1 or tel_idx == -1 or tel_idx <= op_idx:
    print("phase61 workspace boundaries not found; leaving files unchanged")
    sys.exit(0)

section_start = text.rfind("<section", 0, op_idx)
if section_start == -1:
    print("operator section start not found; leaving files unchanged")
    sys.exit(0)

replacement = """          <section id="phase61-operator-column" class="space-y-4" aria-labelledby="operator-tools-heading">
            <div class="flex items-center justify-between">
              <h2 id="operator-tools-heading" class="text-xs uppercase tracking-[0.24em] text-gray-400">
                Operator Workspace
              </h2>
            </div>

            <section id="operator-workspace-card" class="bg-gray-800 p-6 rounded-2xl shadow-lg border border-gray-700" data-workspace-root>
              <div class="flex items-center justify-between mb-4 border-b border-gray-700 pb-3">
                <h2 class="text-xl font-semibold">Operator Workspace</h2>
                <span class="text-xs uppercase tracking-wide text-gray-400">Consolidated</span>
              </div>

              <div id="operator-tabs" role="tablist" aria-label="Operator workspace tabs">
                <button id="op-tab-chat" class="obs-tab active" type="button" data-workspace-tab data-target="op-panel-chat" role="tab" aria-selected="true" aria-controls="op-panel-chat">Chat</button>
                <button id="op-tab-delegation" class="obs-tab" type="button" data-workspace-tab data-target="op-panel-delegation" role="tab" aria-selected="false" aria-controls="op-panel-delegation">Delegation</button>
              </div>

              <div id="operator-panels">
                <div id="op-panel-chat" class="obs-panel active" data-workspace-panel role="tabpanel" aria-labelledby="op-tab-chat">
                  <section id="matilda-chat-card" class="obs-surface">
                    <h2 class="text-xl font-semibold mb-4 border-b border-gray-700 pb-2">Matilda Chat Console</h2>
                    <div id="matilda-chat-root" class="space-y-3">
                      <div id="matilda-chat-transcript" class="bg-gray-900 border border-gray-700 rounded-xl p-3 h-64 overflow-y-auto text-sm">
                        <p class="text-gray-500 italic">Chat with Matilda about tasks, status, or next steps...</p>
                      </div>
                      <div class="flex space-x-3 items-end">
                        <textarea id="matilda-chat-input" rows="3" class="flex-1 bg-gray-900 border border-gray-700 rounded-xl p-3 text-sm resize-none focus:ring-2 focus:ring-purple-500 focus:border-purple-500" placeholder="Type a message to Matilda and press Enter or click Send..."></textarea>
                        <button id="matilda-chat-send" class="px-5 py-2 rounded-xl font-semibold text-sm bg-purple-500 hover:bg-purple-600 focus:outline-none focus:ring-2 focus:ring-purple-400 transition transform hover:-translate-y-0.5 shadow-lg">Send</button>
                        <button id="matilda-chat-quick-check" class="px-3 py-2 rounded-xl font-semibold text-xs bg-gray-700 hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-purple-400 transition shadow-lg">Quick check</button>
                      </div>
                      <p id="matilda-helper-text-ops" class="text-xs text-gray-400 mt-1">Matilda is currently using a placeholder /api/chat stub (Phase 11.3 baseline).</p>
                    </div>
                  </section>
                </div>

                <div id="op-panel-delegation" class="obs-panel" data-workspace-panel role="tabpanel" aria-labelledby="op-tab-delegation" hidden>
                  <section id="delegation-card" class="obs-surface space-y-4">
                    <h2 class="text-xl font-semibold border-b border-gray-700 pb-2">Task Delegation</h2>
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

"""

updated = text[:section_start] + replacement + text[tel_idx:]

updated = updated.replace(
    '<section id="observational-workspace-card" class="bg-gray-800 p-6 rounded-2xl shadow-lg border border-gray-700">',
    '<section id="observational-workspace-card" class="bg-gray-800 p-6 rounded-2xl shadow-lg border border-gray-700" data-workspace-root>',
    1,
)
updated = updated.replace(
    'id="obs-tab-recent"\n                  class="obs-tab active"\n                  type="button"',
    'id="obs-tab-recent"\n                  class="obs-tab active"\n                  type="button"\n                  data-workspace-tab',
    1,
)
updated = updated.replace(
    'id="obs-tab-activity"\n                  class="obs-tab"\n                  type="button"',
    'id="obs-tab-activity"\n                  class="obs-tab"\n                  type="button"\n                  data-workspace-tab',
    1,
)
updated = updated.replace(
    'id="obs-tab-events"\n                  class="obs-tab"\n                  type="button"',
    'id="obs-tab-events"\n                  class="obs-tab"\n                  type="button"\n                  data-workspace-tab',
    1,
)
updated = updated.replace(
    'id="obs-panel-recent" class="obs-panel active" role="tabpanel"',
    'id="obs-panel-recent" class="obs-panel active" data-workspace-panel role="tabpanel"',
    1,
)
updated = updated.replace(
    'id="obs-panel-activity" class="obs-panel" role="tabpanel"',
    'id="obs-panel-activity" class="obs-panel" data-workspace-panel role="tabpanel"',
    1,
)
updated = updated.replace(
    'id="obs-panel-events" class="obs-panel" role="tabpanel"',
    'id="obs-panel-events" class="obs-panel" data-workspace-panel role="tabpanel"',
    1,
)

dashboard.write_text(updated, encoding="utf-8")

tabs_js.write_text(
"""document.addEventListener("DOMContentLoaded", () => {
  const workspaceRoots = Array.from(document.querySelectorAll("[data-workspace-root]"));
  workspaceRoots.forEach((root) => {
    const tabs = Array.from(root.querySelectorAll("[data-workspace-tab]"));
    const panels = Array.from(root.querySelectorAll("[data-workspace-panel]"));
    if (!tabs.length || !panels.length) return;
    const activate = (targetId) => {
      tabs.forEach((tab) => {
        const isActive = tab.dataset.target === targetId;
        tab.classList.toggle("active", isActive);
        tab.setAttribute("aria-selected", String(isActive));
      });
      panels.forEach((panel) => {
        const isActive = panel.id === targetId;
        panel.classList.toggle("active", isActive);
        panel.hidden = !isActive;
      });
    };
    tabs.forEach((tab) => tab.addEventListener("click", () => activate(tab.dataset.target)));
    const defaultTab = tabs.find((tab) => tab.classList.contains("active")) || tabs[0];
    if (defaultTab && defaultTab.dataset.target) activate(defaultTab.dataset.target);
  });
});
""",
    encoding="utf-8",
)

final_text = dashboard.read_text(encoding="utf-8")
for token in [
    'id="operator-workspace-card"',
    'data-workspace-root',
    'id="op-tab-chat"',
    'id="op-tab-delegation"',
    'data-workspace-tab',
    'data-workspace-panel',
]:
    print(f"{token}={token in final_text}")

sys.exit(0)
