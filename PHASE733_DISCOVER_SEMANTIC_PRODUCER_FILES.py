
from pathlib import Path

roots = [Path(".")]

skip_parts = {".git", "node_modules", "backups"}

needles = [

    "MB_SEMANTIC_ARTIFACT_V1",

    "task_summary",

    "actionable_outputs",

    "evidence_notes",

    "raw_markdown_fallback",

    "visual_artifact_generation",

    "Preview Concept Visual Artifact",

]

output = Path("PHASE733_SEMANTIC_PRODUCER_FILE_DISCOVERY.txt")

results = ["=== Phase 733 Semantic Producer File Discovery ===", ""]

for path in Path(".").rglob("*"):

    if not path.is_file():

        continue

    if any(part in skip_parts for part in path.parts):

        continue

    if path.suffix.lower() not in {".ts", ".js", ".mjs", ".cjs", ".json", ".md"}:

        continue

    try:

        text = path.read_text(errors="replace")

    except Exception:

        continue

    hits = [needle for needle in needles if needle in text]

    if hits:

        results.append(f"=== {path} ===")

        results.append("hits: " + ", ".join(hits))

        for idx, line in enumerate(text.splitlines(), start=1):

            if any(needle in line for needle in needles):

                results.append(f"{idx}: {line[:240]}")

        results.append("")

output.write_text("\n".join(results) + "\n")

print(output.read_text())

