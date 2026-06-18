
#!/usr/bin/env bash

set -euo pipefail

python3 - << 'PY'

from pathlib import Path

import re

p = Path("public/dashboard.html")

s = p.read_text()

replacement = '''<script id="phase487-force-confidence-override">

(() => {

  const phase487ReasoningButtonHtml = '<span>Confidence: limited</span><br><button id="phase493-view-reasoning" style="margin-top:6px;font-size:12px;opacity:0.8;">View reasoning</button>';

  function repairConfidenceMeta() {

    const el = document.getElementById("operator-guidance-meta");

    if (!el) return;

    if (el.innerHTML.includes(phase487ReasoningButtonHtml)) {

      el.innerHTML = el.innerHTML.replace(phase487ReasoningButtonHtml, "Confidence: limited");

    }

  }

  if (document.readyState === "loading") {

    document.addEventListener("DOMContentLoaded", repairConfidenceMeta, { once: true });

  } else {

    repairConfidenceMeta();

  }

})();

</script>'''

pattern = re.compile(

    r'<script id="phase487-force-confidence-override">[\s\S]*?</script>',

    re.MULTILINE,

)

s2, count = pattern.subn(replacement, s, count=1)

if count != 1:

    raise SystemExit("phase487-force-confidence-override script block not found or not unique")

p.write_text(s2)

PY

./inspect-dashboard-inline-script-syntax.sh | tee dashboard-inline-script-syntax-after-repair.txt

git diff -- public/dashboard.html dashboard-inline-script-syntax-after-repair.txt

git add public/dashboard.html repair-phase487-confidence-inline-script.sh dashboard-inline-script-syntax-after-repair.txt

git commit -m "Repair Phase487 inline confidence syntax"

git push

