import type { Runbook } from "./operatorRunbookTypes";

export function formatRunbook(runbook: Runbook): string {
  const steps = runbook.steps
    .map((s, i) => `${i + 1}. ${s.description}`)
    .join("\n");

  return [
    "OPERATOR RUNBOOK",
    `Runbook: ${runbook.title}`,
    `Risk: ${runbook.risk}`,
    `State: ${runbook.state}`,
    "",
    "STEPS",
    steps,
    "",
    `SAFE TO CONTINUE: ${runbook.continueSafe ? "YES" : "NO"}`
  ].join("\n");
}
