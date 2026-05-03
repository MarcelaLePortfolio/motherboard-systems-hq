from pathlib import Path
import re

target = Path("public/index.html")
text = target.read_text()

style_id = "phase490-evidence-based-height-fix"

block = """
<style id="phase490-evidence-based-height-fix">
  /* Phase 490 — evidence-based fix:
     telemetry cards showed non-zero bottom margin and flex: 0 1 auto.
     Normalize workspace surface cards without mutating outer layout. */

  #chat-card,
  #delegation-card,
  #recent-tasks-card,
  #task-activity-card,
  #task-events-card {
    margin-bottom: 0 !important;
    flex: 1 1 auto !important;
    min-height: 0 !important;
    box-sizing: border-box !important;
  }

  #op-panel-chat,
  #op-panel-delegation,
  #obs-panel-recent,
  #obs-panel-activity,
  #obs-panel-events {
    min-height: 0 !important;
  }

  #chat-card,
  #delegation-card,
  #recent-tasks-card,
  #task-activity-card,
  #task-events-card,
  #observational-panels > .obs-panel:not([hidden]),
  #operator-panels > *:not([hidden]) {
    display: flex !important;
    flex-direction: column !important;
  }

  #matilda-chat-transcript,
  #delegation-status-panel,
  #mb-task-events-panel-anchor {
    flex: 1 1 auto !important;
    min-height: 0 !important;
    overflow-y: auto !important;
  }

  #task-activity-card > div,
  #task-activity-graph {
    flex: 1 1 auto !important;
    min-height: 0 !important;
    height: 100% !important;
    max-height: 100% !important;
  }
</style>
"""

text = re.sub(
    r'<style id="phase490-evidence-based-height-fix">.*?</style>\s*',
    '',
    text,
    flags=re.S
)

anchor = '<style id="phase489-task-activity-scroll">'
if anchor in text:
    text = text.replace(anchor, block + "\n" + anchor, 1)
else:
    fallback = '    <style>\n'
    if fallback in text:
        text = text.replace(fallback, fallback + block + "\n", 1)
    else:
        raise SystemExit("Could not find insertion point for evidence-based height fix")

target.write_text(text)
print("Applied evidence-based workspace card height fix.")
