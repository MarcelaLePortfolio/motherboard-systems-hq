from pathlib import Path
import re

target = Path("public/index.html")
text = target.read_text()

style_id = "phase490-telemetry-card-height-force"

block = """
<style id="phase490-telemetry-card-height-force">
  #recent-tasks-card,
  #task-activity-card,
  #task-events-card {
    height: var(--phase490-telemetry-card-height) !important;
    min-height: var(--phase490-telemetry-card-height) !important;
    max-height: var(--phase490-telemetry-card-height) !important;
    box-sizing: border-box !important;
    display: flex !important;
    flex-direction: column !important;
    flex: 0 0 auto !important;
    overflow: hidden !important;
  }

  #recentTasks,
  #recentLogs,
  #mb-task-events-panel-anchor {
    flex: 1 1 auto !important;
    min-height: 0 !important;
    overflow-y: auto !important;
  }

  #task-activity-card > div {
    flex: 1 1 auto !important;
    min-height: 0 !important;
    height: 100% !important;
    max-height: 100% !important;
    display: flex !important;
    overflow: hidden !important;
  }

  #task-activity-graph {
    flex: 1 1 auto !important;
    min-height: 0 !important;
    height: 100% !important;
    max-height: 100% !important;
  }
</style>
"""

text = re.sub(
    r'<style id="phase490-telemetry-card-height-force">.*?</style>\s*',
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
        raise SystemExit("Could not find insertion point for telemetry card height force block")

target.write_text(text)
print("Applied CSS-variable-forced telemetry card heights.")
