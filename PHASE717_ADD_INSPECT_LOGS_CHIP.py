
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old_compute = '''      const traceJson = trace ? esc(JSON.stringify(trace, null, 2)) : "";'''

new_compute = '''      const traceJson = trace ? esc(JSON.stringify(trace, null, 2)) : "";

      const logLines = [

        `task_id=${taskId}`,

        `status=${status}`,

        updated ? `updated=${updated}` : "",

        outcome ? `outcome=${outcome}` : "",

        explanation ? `details=${explanation}` : ""

      ].filter(Boolean).join("\\n");

      const logContent = esc(logLines);'''

old_buttons = '''            ${explanation ? `<button type="button" data-phase717-inspect-details="true" data-phase717-inspect-title="${title} — Details" data-phase717-inspect-content="${explanation}" style="margin-top:8px;cursor:pointer;border:1px solid rgba(147,197,253,.35);background:rgba(30,64,175,.14);color:#93c5fd;border-radius:999px;padding:4px 8px;font-size:11px;">Inspect details</button>` : ""}

            ${traceJson ? `<button type="button" data-phase717-inspect-trace="true" data-phase717-inspect-title="${title} — Advanced trace" data-phase717-inspect-content="${traceJson}" style="margin-top:6px;margin-left:6px;cursor:pointer;border:1px solid rgba(251,191,36,.38);background:rgba(120,53,15,.14);color:#fbbf24;border-radius:999px;padding:4px 8px;font-size:11px;">Inspect trace</button>` : ""}'''

new_buttons = '''            ${explanation ? `<button type="button" data-phase717-inspect-details="true" data-phase717-inspect-title="${title} — Details" data-phase717-inspect-content="${explanation}" style="margin-top:8px;cursor:pointer;border:1px solid rgba(147,197,253,.35);background:rgba(30,64,175,.14);color:#93c5fd;border-radius:999px;padding:4px 8px;font-size:11px;">Inspect details</button>` : ""}

            ${traceJson ? `<button type="button" data-phase717-inspect-trace="true" data-phase717-inspect-title="${title} — Advanced trace" data-phase717-inspect-content="${traceJson}" style="margin-top:6px;margin-left:6px;cursor:pointer;border:1px solid rgba(251,191,36,.38);background:rgba(120,53,15,.14);color:#fbbf24;border-radius:999px;padding:4px 8px;font-size:11px;">Inspect trace</button>` : ""}

            ${logContent ? `<button type="button" data-phase717-inspect-logs="true" data-phase717-inspect-title="${title} — Logs" data-phase717-inspect-content="${logContent}" style="margin-top:6px;margin-left:6px;cursor:pointer;border:1px solid rgba(45,212,191,.38);background:rgba(20,83,45,.14);color:#5eead4;border-radius:999px;padding:4px 8px;font-size:11px;">Inspect logs</button>` : ""}'''

old_handler = '''    const traceButton = event.target.closest("[data-phase717-inspect-trace]");

    const inspectionButton = detailButton || traceButton;'''

new_handler = '''    const traceButton = event.target.closest("[data-phase717-inspect-trace]");

    const logsButton = event.target.closest("[data-phase717-inspect-logs]");

    const inspectionButton = detailButton || traceButton || logsButton;'''

for old, new in [(old_compute, new_compute), (old_buttons, new_buttons), (old_handler, new_handler)]:

    if old not in text:

        raise SystemExit(f"EXPECTED BLOCK NOT FOUND:\\n{old}")

    text = text.replace(old, new, 1)

path.write_text(text)

print("Inspect logs chip added.")

