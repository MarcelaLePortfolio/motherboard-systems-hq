
#!/bin/bash

set -e

python3 <<'PY'

from pathlib import Path

p = Path("public/dashboard.html")

text = p.read_text()

marker = '''    const statusIcon = ready ? "✓" : payload.inputPath ? "✕" : "•";'''

insert = '''    if (ready) {

      pathStatus.style.borderColor = "rgba(45, 212, 191, 0.65)";

      pathStatus.style.backgroundColor = "rgba(19, 78, 74, 0.42)";

      pathStatus.style.color = "#ccfbf1";

    } else if (payload.inputPath || message !== "Enter a path to inspect the repository.") {

      pathStatus.style.borderColor = "rgba(248, 113, 113, 0.75)";

      pathStatus.style.backgroundColor = "rgba(127, 29, 29, 0.42)";

      pathStatus.style.color = "#fee2e2";

    } else {

      pathStatus.style.borderColor = "rgba(55, 65, 81, 1)";

      pathStatus.style.backgroundColor = "rgba(17, 24, 39, 1)";

      pathStatus.style.color = "#9ca3af";

    }

'''

if marker not in text:

    raise SystemExit("status icon marker not found.")

if "pathStatus.style.borderColor" not in text:

    text = text.replace(marker, insert + marker, 1)

p.write_text(text)

PY

grep -n "pathStatus.style.borderColor\|pathStatus.style.backgroundColor\|pathStatus.style.color" public/dashboard.html

git add public/dashboard.html

git commit -m "Fix Project Registry path status card colors"

git push

git add fix-project-path-status-card-colors-v2b.sh

git commit -m "Add Project Registry V2-B status color fix script"

git push

