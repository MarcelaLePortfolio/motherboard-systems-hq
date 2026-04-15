from pathlib import Path

target = Path("public/index.html")
text = target.read_text()

style_id = "phase490-height-contract"

block = """
<style id="phase490-height-contract">
  /* === ROOT LAYOUT CONTRACT === */
  #phase61-main-grid,
  #phase61-main-grid > section {
    display: flex;
    align-items: stretch;
  }

  /* === BOTH COLUMNS MATCH HEIGHT === */
  #operator-workspace-card,
  #observational-workspace-card {
    height: 100%;
    display: flex;
    flex-direction: column;
  }

  /* === PANELS FILL THEIR COLUMN === */
  #op-panel-chat,
  #op-panel-delegation,
  #observational-panels {
    flex: 1 1 auto;
    display: flex;
    flex-direction: column;
    min-height: 0;
  }

  /* === EACH TAB PANEL FILLS SAME HEIGHT === */
  .obs-panel {
    flex: 1 1 auto;
    display: flex;
    flex-direction: column;
    min-height: 0;
  }

  /* === INNER CONTENT SCROLLS (NOT CONTAINERS) === */
  #recentTasks,
  #recentLogs,
  #mb-task-events-panel-anchor {
    overflow-y: auto;
    flex: 1 1 auto;
    min-height: 0;
  }

  /* === TASK ACTIVITY GRAPH FITS === */
  #task-activity-card > div {
    flex: 1 1 auto;
    display: flex;
    min-height: 0;
  }

  #task-activity-graph {
    height: 100% !important;
    flex: 1 1 auto;
  }

  /* === DELEGATION MATCHES CHAT STRUCTURE === */
  #delegation-status-panel {
    flex: 1 1 auto;
    overflow-y: auto;
    min-height: 0;
  }
</style>
"""

if style_id not in text:
    anchor = "<style"
    idx = text.find(anchor)
    if idx != -1:
        text = text[:idx] + block + "\n" + text[idx:]
    else:
        raise SystemExit("Could not find style insertion point")

target.write_text(text)
print("Applied Phase 490 height contract.")
