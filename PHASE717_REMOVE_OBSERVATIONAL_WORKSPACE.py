
from pathlib import Path

path = Path("public/index.html")

text = path.read_text()

start_marker = '          <section id="observational-workspace-card"'

end_marker = '          <section id="atlas-status-card"'

start = text.find(start_marker)

end = text.find(end_marker, start)

if start == -1 or end == -1:

    raise SystemExit("OBSERVATIONAL WORKSPACE BLOCK BOUNDS NOT FOUND")

removed = text[start:end]

text = text[:start] + text[end:]

script_lines = [

    '  <script defer src="js/phase490_telemetry_height_probe.js"></script>\n',

    '  <script defer src="js/phase490_operator_height_probe.js"></script>\n',

    '  <script defer src="js/phase490_matilda_piece_debug.js"></script>\n',

    '  <script defer src="js/phase490_operator_height_beacon.js"></script>\n',

    '  <script defer src="js/phase490_height_evidence_capture.js"></script>\n',

    '  <script defer src="js/phase489_panel_height_sync.js"></script>\n',

    '  <script defer src="js/phase457_restore_task_panels.js"></script>\n',

    '  <script defer src="js/task-events-sse-client.js"></script>\n',

    '  <script defer src="js/phase530_dom_probe.js"></script>\n',

    '  <script defer src="js/phase531_recent_tasks_layout_fix.js"></script>\n',

    '  <script defer src="js/phase532_task_history_fill_fix.js"></script>\n',

]

for line in script_lines:

    text = text.replace(line, "")

path.write_text(text)

print("Removed Observational Workspace block:")

print(removed[:500])

print("...")

