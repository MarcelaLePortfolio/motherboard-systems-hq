from pathlib import Path
import re

target = Path("public/index.html")
text = target.read_text()

# Remove prior runtime sync mount if still present
text = text.replace('  <script defer src="js/phase489_panel_height_sync.js"></script>\n', '')

# Remove previous Phase 490 height block if present
text = re.sub(
    r'<style id="phase490-height-contract">.*?</style>\s*',
    '',
    text,
    flags=re.S
)

new_block = """
<style id="phase490-height-contract">
  /* === authoritative two-column row contract === */
  #phase61-workspace-grid {
    display: grid !important;
    grid-template-columns: 1fr 1fr !important;
    align-items: stretch !important;
  }

  #phase61-workspace-grid > div,
  #phase61-workspace-grid > section,
  #phase61-operator-column,
  #phase61-telemetry-column {
    min-height: 0 !important;
    height: 100% !important;
    display: flex !important;
    flex-direction: column !important;
  }

  /* === cards must share the same row height === */
  #operator-workspace-card,
  #observational-workspace-card {
    flex: 1 1 auto !important;
    min-height: 0 !important;
    height: 100% !important;
    display: flex !important;
    flex-direction: column !important;
  }

  /* === operator panels === */
  #operator-panels,
  #op-panel-chat,
  #op-panel-delegation {
    flex: 1 1 auto !important;
    min-height: 0 !important;
    height: 100% !important;
    display: flex !important;
    flex-direction: column !important;
  }

  #chat-card,
  #delegation-card {
    flex: 1 1 auto !important;
    min-height: 0 !important;
    height: 100% !important;
    display: flex !important;
    flex-direction: column !important;
  }

  #matilda-chat-transcript,
  #delegation-status-panel {
    flex: 1 1 auto !important;
    min-height: 0 !important;
    overflow-y: auto !important;
  }

  #delegation-input {
    min-height: 8rem !important;
  }

  /* === telemetry panels === */
  #observational-panels,
  #obs-panel-recent,
  #obs-panel-activity,
  #obs-panel-events {
    flex: 1 1 auto !important;
    min-height: 0 !important;
    height: 100% !important;
    display: flex !important;
    flex-direction: column !important;
  }

  #recent-tasks-card,
  #task-activity-card,
  #task-events-card {
    flex: 1 1 auto !important;
    min-height: 0 !important;
    height: 100% !important;
    display: flex !important;
    flex-direction: column !important;
  }

  /* recent tasks panel */
  #recent-tasks-card > div {
    min-height: 0 !important;
  }

  #recentTasks,
  #recentLogs {
    overflow-y: auto !important;
  }

  /* task activity panel */
  #task-activity-card > div {
    flex: 1 1 auto !important;
    min-height: 0 !important;
    height: 100% !important;
    display: flex !important;
  }

  #task-activity-graph {
    flex: 1 1 auto !important;
    min-height: 0 !important;
    height: 100% !important;
    max-height: 100% !important;
  }

  /* task events panel */
  #mb-task-events-panel-anchor {
    flex: 1 1 auto !important;
    min-height: 0 !important;
    overflow-y: auto !important;
  }

  /* hidden tab panels should stay hidden */
  .obs-panel[hidden],
  .obs-panel[aria-hidden="true"],
  #op-panel-delegation[hidden],
  #op-panel-delegation[aria-hidden="true"] {
    display: none !important;
  }

  /* active panels should fill available height */
  .obs-panel.active:not([hidden]),
  #op-panel-chat:not([hidden]),
  #op-panel-delegation.active:not([hidden]) {
    display: flex !important;
  }
</style>
"""

insert_anchor = '    <style>\n'
if insert_anchor not in text:
    raise SystemExit("Could not find base style insertion anchor in public/index.html")

text = text.replace(insert_anchor, insert_anchor + new_block + "\n", 1)

target.write_text(text)
print("Applied stronger Phase 490 height contract to actual dashboard anchors.")
