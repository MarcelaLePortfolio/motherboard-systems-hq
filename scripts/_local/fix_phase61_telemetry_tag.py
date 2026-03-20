#!/usr/bin/env python3
from pathlib import Path

p = Path("public/dashboard.html")
text = p.read_text(encoding="utf-8")

bad_variants = [
    '\n  id="phase61-telemetry-column" class="space-y-4" aria-labelledby="activity-panels-heading">',
    '\nid="phase61-telemetry-column" class="space-y-4" aria-labelledby="activity-panels-heading">',
    '\n        id="phase61-telemetry-column" class="space-y-4" aria-labelledby="activity-panels-heading">',
    '\n          id="phase61-telemetry-column" class="space-y-4" aria-labelledby="activity-panels-heading">',
]

good = '\n          <section id="phase61-telemetry-column" class="space-y-4" aria-labelledby="activity-panels-heading">'

for bad in bad_variants:
    if bad in text:
        text = text.replace(bad, good, 1)
        break

p.write_text(text, encoding="utf-8")
