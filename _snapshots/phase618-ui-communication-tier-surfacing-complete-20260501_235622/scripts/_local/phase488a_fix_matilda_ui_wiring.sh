#!/bin/bash
set -euo pipefail

TARGET="public/index.html"

echo "=== verifying target ==="
[ -f "$TARGET" ] || { echo "index.html not found"; exit 1; }

echo
echo "=== injecting minimal Matilda UI handler (surgical) ==="

python3 << 'PY'
from pathlib import Path

path = Path("public/index.html")
text = path.read_text()

marker = "</body>"

injection = """
<script>
(function () {
  const input = document.querySelector('input[placeholder*="Matilda"]') || document.querySelector('input');
  const button = document.querySelector('button');
  const output = document.createElement("pre");
  output.id = "matilda-output";
  output.style.whiteSpace = "pre-wrap";
  output.style.marginTop = "12px";

  if (input && button) {
    button.parentNode.appendChild(output);

    button.addEventListener("click", async () => {
      const message = input.value || "";
      if (!message.trim()) return;

      output.textContent = "…";

      try {
        const res = await fetch("/api/chat", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ message, agent: "matilda" })
        });

        const data = await res.json();
        output.textContent = data.reply || JSON.stringify(data, null, 2);
      } catch (err) {
        output.textContent = "UI error: " + err.message;
      }
    });
  }
})();
</script>
"""

if injection.strip() in text:
    print("Already injected, skipping.")
else:
    text = text.replace(marker, injection + "\n" + marker)
    path.write_text(text)
    print("Injection complete.")
PY

git add public/index.html
git commit -m "Inject minimal Matilda UI handler to restore chat response rendering"
git push

echo
echo "=== rebuild container ==="
docker compose build dashboard
docker compose up -d dashboard

echo
echo "=== quick UI test ==="
echo "Open http://127.0.0.1:8080 and click send in Matilda panel"
