
from pathlib import Path

import re

targets = [

    "server.ts",

    "matilda_task_processor.ts",

    "tasks.ts",

    "routes/api/tasks.ts",

    "routes/api/delegate.ts",

    "routes/delegate.ts",

    "routes/tasks.ts",

]

pattern = re.compile(

    r"MB_SEMANTIC_ARTIFACT_V1|task_summary|actionable_outputs|evidence_notes|raw_markdown_fallback|artifact-preview|visual-artifact|compiler_options|execution_meta|artifact",

    re.IGNORECASE,

)

output = Path("PHASE733_TARGETED_SEMANTIC_PRODUCER_INSPECTION.txt")

lines = ["=== Phase 733 Targeted Semantic Producer Inspection ===", ""]

for target in targets:

    path = Path(target)

    lines.append(f"=== TARGET: {target} ===")

    if not path.exists():

        lines.append("missing")

        lines.append("")

        continue

    content = path.read_text(errors="replace").splitlines()

    matches = [

        f"{idx}: {line}"

        for idx, line in enumerate(content, start=1)

        if pattern.search(line)

    ]

    lines.extend(matches or ["no matches"])

    lines.append("")

output.write_text("\n".join(lines) + "\n")

print(output.read_text())

