from pathlib import Path

target = Path("public/index.html")
text = target.read_text()

style_id = "phase489-unified-panel-heights"

block = """
<style id="phase489-unified-panel-heights">
  /* Match all right-side panels + delegation to chat pane height */
  #observational-workspace-card,
  #delegation-status-panel,
  #recent-tasks-card,
  #task-activity-card,
  #task-events-card {
    height: 100%;
    min-height: 0;
  }

  /* Make telemetry + delegation containers flex correctly */
  #observational-panels,
  [data-workspace-root],
  #phase61-telemetry-column {
    display: flex;
    flex-direction: column;
    height: 100%;
    min-height: 0;
  }

  /* Panels stretch evenly */
  .obs-panel {
    flex: 1 1 auto;
    min-height: 0;
    display: flex;
    flex-direction: column;
  }

  /* Scrollable content areas */
  #recentTasks,
  #recentLogs,
  #mb-task-events-panel-anchor {
    flex: 1 1 auto;
    overflow-y: auto;
    min-height: 0;
  }

  /* Task Activity graph fills available space */
  #task-activity-card > div {
    flex: 1 1 auto;
    min-height: 0;
    display: flex;
  }

  #task-activity-graph {
    flex: 1 1 auto !important;
    height: 100% !important;
  }
</style>
"""

if style_id not in text:
    insert_anchor = '<style id="phase489-task-activity-scroll">'
    if insert_anchor in text:
        text = text.replace(insert_anchor, block + "\\n" + insert_anchor, 1)
    else:
        fallback_anchor = '<style'
        idx = text.find(fallback_anchor)
        if idx != -1:
            text = text[:idx] + block + "\\n" + text[idx:]
        else:
            raise SystemExit("Could not find insertion point for unified panel heights")

target.write_text(text)
print("Unified panel heights with Matilda chat pane.")
