from pathlib import Path
import re
import sys

path = Path("src/cognition/operatorGuidanceConfidence.ts")

if not path.exists():
    sys.exit("operatorGuidanceConfidence.ts not found")

text = path.read_text()

if 'import type { OperationalConfidence } from "./confidence";' not in text:
    text = 'import type { OperationalConfidence } from "./confidence";\n' + text

if "export interface OperatorGuidanceConfidenceInput" in text:
    if "operationalConfidence?: OperationalConfidence;" not in text:
        text = text.replace(
            "export interface OperatorGuidanceConfidenceInput {",
            "export interface OperatorGuidanceConfidenceInput {\n  operationalConfidence?: OperationalConfidence;",
            1,
        )
else:
    if "export interface OperatorGuidanceConfidenceInput {" not in text:
        insert_after = re.search(
            r'import type \{ OperationalConfidence \} from "\./confidence";\n',
            text,
        )
        if not insert_after:
            sys.exit("Could not locate confidence import insertion point.")
        text = (
            text[: insert_after.end()]
            + '\nexport interface OperatorGuidanceConfidenceInput {\n  operationalConfidence?: OperationalConfidence;\n}\n'
            + text[insert_after.end() :]
        )

if "export function mapOperationalConfidenceToGuidanceModifier(" not in text:
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
