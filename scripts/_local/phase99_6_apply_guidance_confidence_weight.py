from pathlib import Path
import re
import sys

target = Path("src/cognition/operatorGuidanceReducer.ts")

if not target.exists():
    sys.exit("src/cognition/operatorGuidanceReducer.ts not found")

text = target.read_text()

import_line = 'import { confidencePriorityWeight } from "./operatorGuidanceConfidence";\n'
if 'from "./operatorGuidanceConfidence"' not in text:
    if text.startswith("import "):
        text = import_line + text
    else:
        text = import_line + "\n" + text

helper = """
function applyOperationalConfidencePriorityWeight(
  priority: number,
  confidence?: import("./confidence").OperationalConfidence,
): number {
  return Math.round(priority * confidencePriorityWeight(confidence));
}

"""

if "function applyOperationalConfidencePriorityWeight(" not in text:
    import_block_end = 0
    for match in re.finditer(r"^import .*?;\n", text, flags=re.MULTILINE):
        import_block_end = match.end()
    text = text[:import_block_end] + ("\n" if import_block_end else "") + helper + text[import_block_end:]

replacements = [
    (
        r"priority:\s*([A-Za-z0-9_\.]+),",
        r"priority: applyOperationalConfidencePriorityWeight(\1, input.operationalConfidence),",
    ),
    (
        r"priority\s*=\s*([A-Za-z0-9_\.]+);",
        r"priority = applyOperationalConfidencePriorityWeight(\1, input.operationalConfidence);",
    ),
]

changed = False
for pattern, replacement in replacements:
    new_text, count = re.subn(pattern, replacement, text, count=1)
    if count > 0:
        text = new_text
        changed = True
        break

if not changed:
    sys.exit("Could not locate priority assignment pattern in operatorGuidanceReducer.ts")

target.write_text(text)
print(f"Patched: {target}")
