#!/usr/bin/env python3
from pathlib import Path
import sys

p = Path("public/dashboard.html")
text = p.read_text(encoding="utf-8")

op_token = 'id="phase61-operator-column"'
subsystem_token = 'aria-labelledby="subsystem-status-heading"'

op_idx = text.find(op_token)
sub_idx = text.find(subsystem_token)

print(f"operator_token_found={op_idx != -1}")
print(f"subsystem_token_found={sub_idx != -1}")

if op_idx == -1 or sub_idx == -1 or sub_idx <= op_idx:
    print("workspace boundary detection failed; no changes written")
    sys.exit(0)

op_start = text.rfind("<section", 0, op_idx)
sub_start = text.rfind("<section", 0, sub_idx)

print(f"operator_section_start_found={op_start != -1}")
print(f"subsystem_section_start_found={sub_start != -1}")

if op_start == -1 or sub_start == -1 or sub_start <= op_start:
    print("section boundary detection failed; no changes written")
    sys.exit(0)

workspace_region = """          <section id="phase61-operator-column" class="space-y-4" aria-labelledby="operator-tools-heading">
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
          </section>

          <section id="phase61-telemetry-column" class="space-y-4" aria-labelledby="activity-panels-heading">
            <div class="flex items-center justify-between">
              <h2 id="activity-panels-heading" class="text-xs uppercase tracking-[0.24em] text-gray-400">
                Observational Workspace
              </h2>
            </div>

            <section id="observational-workspace-card" class="bg-gray-800 p-6 rounded-2xl shadow-lg border border-gray-700" data-workspace-root>
              <div class="flex items-center justify-between mb-4 border-b border-gray-700 pb-3">
                <h2 class="text-xl font-semibold">Telemetry Workspace</h2>
                <span class="text-xs uppercase tracking-wide text-gray-400">Consolidated</span>
              </div>

              <div id="observational-tabs" role="tablist" aria-label="Observational workspace tabs">
                <button id="obs-tab-recent" class="obs-tab active" type="button" data-workspace-tab data-target="obs-panel-recent" role="tab" aria-selected="true" aria-controls="obs-panel-recent">
                  Recent Tasks
                </button>
                <button id="obs-tab-activity" class="obs-tab" type="button" data-workspace-tab data-target="obs-panel-activity" role="tab" aria-selected="false" aria-controls="obs-panel-activity">
                  Task Activity
                </button>
                <button id="obs-tab-events" class="obs-tab" type="button" data-workspace-tab data-target="obs-panel-events" role="tab" aria-selected="false" aria-controls="obs-panel-events">
                  Task Events
                </button>
              </div>

              <div id="observational-panels">
                <div id="obs-panel-recent" class="obs-panel active" data-workspace-panel role="tabpanel" aria-labelledby="obs-tab-recent">
                  <section id="recent-tasks-card" class="obs-surface">
                    <div class="flex items-center justify-between mb-4 border-b border-gray-700 pb-2">
                      <h2 class="text-xl font-semibold">Recent Tasks</h2>
                      <span class="text-xs uppercase tracking-wide text-indigo-300/80">Live</span>
                    </div>
                    <div id="tasks-widget"></div>
                  </section>
                </div>

                <div id="obs-panel-activity" class="obs-panel" data-workspace-panel role="tabpanel" aria-labelledby="obs-tab-activity" hidden>
                  <section id="task-activity-card" class="obs-surface">
                    <h2 class="text-xl font-semibold mb-4 border-b border-gray-700 pb-2">Task Activity Over Time</h2>
                    <div class="h-64">
                      <canvas id="task-activity-graph" class="w-full h-full"></canvas>
                    </div>
                  </section>
                </div>

                <div id="obs-panel-events" class="obs-panel" data-workspace-panel role="tabpanel" aria-labelledby="obs-tab-events" hidden>
                  <section id="task-events-card" class="obs-surface">
                    <div class="flex items-center justify-between mb-4 border-b border-gray-700 pb-2">
                      <h2 class="text-xl font-semibold">Task Events Stream</h2>
                      <span class="text-xs uppercase tracking-wide text-teal-300/80">SSE</span>
                    </div>
                    <div id="mb-task-events-panel-anchor"></div>
                  </section>
                </div>
              </div>
            </section>
          </section>

"""

updated = text[:op_start] + workspace_region + text[sub_start:]
p.write_text(updated, encoding="utf-8")
print("workspace region rewritten")
