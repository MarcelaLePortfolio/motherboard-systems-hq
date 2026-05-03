from pathlib import Path
import sys

target = Path("src/cognition/operatorGuidanceConfidence.ts")

if not target.exists():
    sys.exit("src/cognition/operatorGuidanceConfidence.ts not found")

text = target.read_text()

if 'import type { OperationalConfidence } from "./confidence";' not in text:
    text = 'import type { OperationalConfidence } from "./confidence";\n' + text

if "export function confidencePriorityWeight(" not in text:
    text += """

export function confidencePriorityWeight(
  confidence?: OperationalConfidence,
): number {
  if (!confidence) {
    return 1;
  }

  switch (confidence.level) {
    case "HIGH":
      return 1;
    case "MEDIUM":
      return 1.1;
    case "LOW":
      return 1.25;
    default:
      return 1;
  }
}
"""

target.write_text(text)
print(f"Patched: {target}")
