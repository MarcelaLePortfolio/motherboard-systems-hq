import { resolveOperatorRunbook } from "../dashboard/src/operator/runbooks/operatorRunbookResolver";
import { formatRunbook } from "../dashboard/src/operator/runbooks/operatorRunbookFormatter";

const sample = resolveOperatorRunbook({
  diagnosticsClean: true,
  driftDetected: false,
  structuralRisk: false
});

console.log(formatRunbook(sample));
