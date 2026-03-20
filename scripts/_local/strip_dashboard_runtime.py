from pathlib import Path
import re

TARGETS = [
    Path("public/dashboard.html"),
    Path("public/index.html"),
]

SCRIPT_PATTERNS = [
    r'<script[^>]+src="/js/phase16_sse_backoff\.js[^"]*"[^>]*></script>\s*',
    r'<script[^>]+src="/js/phase16_sse_owner_ops_reflections\.js[^"]*"[^>]*></script>\s*',
    r'<script[^>]+src="/bundle\.js[^"]*"[^>]*></script>\s*',
    r'<script[^>]+src="/js/phase16_reflections_ui_consumer\.js[^"]*"[^>]*></script>\s*',
    r'<script[^>]+src="/js/phase13_5_operator_ux\.js[^"]*"[^>]*></script>\s*',
    r'<script[^>]+src="/js/phase23_matilda_chat_hook\.js[^"]*"[^>]*></script>\s*',
    r'<script[^>]+src="/js/phase23_matilda_delegate_taskspec\.js[^"]*"[^>]*></script>\s*',
    r'<script[^>]+src="/js/phase23_matilda_task_events_bridge\.js[^"]*"[^>]*></script>\s*',
    r'<script[^>]+src="/js/dashboard-ops-reflections-ui\.js[^"]*"[^>]*></script>\s*',
    r'<script[^>]+src="/js/phase16_sse_status_indicator\.js[^"]*"[^>]*></script>\s*',
]

BLOCK_PATTERNS = [
    r'<!-- PHASE16: reflections UI panel \(safe, minimal\) -->.*?<!-- /PHASE16 reflections UI panel -->\s*',
    r'<!-- PHASE16: inline beacon \(debug\) -->.*?<!-- /PHASE16: inline beacon \(debug\) -->\s*',
    r'<!-- PHASE16: Reflections SSE owner -->.*?<!-- /PHASE16: Reflections SSE owner -->\s*',
    r'<!-- PHASE16: reflections UI consumer -->.*?<!-- /PHASE16: reflections UI consumer -->\s*',
    r'<div id="phase16-sse-indicator".*?</div>\s*<script defer src="/js/phase16_sse_status_indicator\.js"></script>\s*',
    r'<div\s+id="phase16_reflections_panel".*?</div>\s*',
]

STATIC_BEACON = """  <script>
    console.log("[diag] dashboard static isolation mode active");
  </script>
"""

for path in TARGETS:
    if not path.exists():
        continue
    text = path.read_text()
    original = text

    for pattern in SCRIPT_PATTERNS:
        text = re.sub(pattern, "", text, flags=re.S)

    for pattern in BLOCK_PATTERNS:
        text = re.sub(pattern, "", text, flags=re.S)

    if STATIC_BEACON not in text and "</body>" in text:
        text = text.replace("</body>", f"{STATIC_BEACON}\n</body>", 1)

    if text != original:
        path.write_text(text)

print("done")
