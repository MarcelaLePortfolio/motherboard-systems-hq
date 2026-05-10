
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

needle = '      const traceJson = trace ? esc(JSON.stringify(trace, null, 2)) : "";'

insert = '''      const traceJson = trace ? esc(JSON.stringify(trace, null, 2)) : "";

      const logLines = [

        `task_id=${taskId}`,

        `status=${status}`,

        updated ? `updated=${updated}` : "",

        outcome ? `outcome=${outcome}` : "",

        explanation ? `details=${explanation}` : ""

      ].filter(Boolean).join("\\n");

      const logContent = esc(logLines);'''

if needle not in text:

    raise SystemExit("TRACE JSON ANCHOR NOT FOUND")

text = text.replace(needle, insert, 1)

trace_line = '            ${traceJson ? `<button type="button" data-phase717-inspect-trace="true" data-phase717-inspect-title="${title} — Advanced trace" data-phase717-inspect-content="${traceJson}" style="margin-top:6px;margin-left:6px;cursor:pointer;border:1px solid rgba(251,191,36,.38);background:rgba(120,53,15,.14);color:#fbbf24;border-radius:999px;padding:4px 8px;font-size:11px;">Inspect trace</button>` : ""}'

logs_line = '''            ${logContent ? `<button type="button" data-phase717-inspect-logs="true" data-phase717-inspect-title="${title} — Logs" data-phase717-inspect-content="${logContent}" style="margin-top:6px;margin-left:6px;cursor:pointer;border:1px solid rgba(45,212,191,.38);background:rgba(20,83,45,.14);color:#5eead4;border-radius:999px;padding:4px 8px;font-size:11px;">Inspect logs</button>` : ""}'''

if trace_line not in text:

    raise SystemExit("TRACE BUTTON LINE NOT FOUND")

text = text.replace(trace_line, trace_line + "\\n\\n" + logs_line, 1)

handler_old = '''    const traceButton = event.target.closest("[data-phase717-inspect-trace]");

    const inspectionButton = detailButton || traceButton;'''

handler_new = '''    const traceButton = event.target.closest("[data-phase717-inspect-trace]");

    const logsButton = event.target.closest("[data-phase717-inspect-logs]");

    const inspectionButton = detailButton || traceButton || logsButton;'''

if handler_old not in text:

    raise SystemExit("INSPECTION HANDLER ANCHOR NOT FOUND")

text = text.replace(handler_old, handler_new, 1)

path.write_text(text)

print("Inspect logs chip safely added to renderer.")

