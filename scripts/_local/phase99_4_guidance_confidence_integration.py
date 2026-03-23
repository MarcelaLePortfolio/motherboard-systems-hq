from pathlib import Path
import sys

path = Path("src/cognition/operatorGuidanceConfidence.ts")

if not path.exists():
    sys.exit("operatorGuidanceConfidence.ts not found")

text = path.read_text()

if "OperationalConfidence" not in text:
    text = 'import type { OperationalConfidence } from "./confidence";\n' + text

if "operationalConfidence?: OperationalConfidence;" not in text:
    text = text.replace(
        "export interface OperatorGuidanceConfidenceInput {",
        "export interface OperatorGuidanceConfidenceInput {\n  operationalConfidence?: OperationalConfidence;"
    )

if "operationalConfidence?.level" not in text:
    text += """

export function mapOperationalConfidenceToGuidanceModifier(
  confidence?: OperationalConfidence,
): number {
  if (!confidence) return 0;

  if (confidence.level === "HIGH") return 1;
  if (confidence.level === "MEDIUM") return 0;
  if (confidence.level === "LOW") return -1;

  return 0;
}
"""

path.write_text(text)
