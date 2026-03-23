from pathlib import Path
import sys

target = None

for p in Path("src").rglob("*guidance*confidence*.ts"):
    target = p
    break

if not target:
    sys.exit("guidance confidence file not found")

text = target.read_text()

if "confidencePriorityWeight" not in text:
    text += """

export function confidencePriorityWeight(confidence?: OperationalConfidence): number {
  if (!confidence) return 1

  switch (confidence.level) {
    case "HIGH":
      return 1
    case "MEDIUM":
      return 1.1
    case "LOW":
      return 1.25
    default:
      return 1
  }
}
"""

target.write_text(text)

print("Patched:", target)
