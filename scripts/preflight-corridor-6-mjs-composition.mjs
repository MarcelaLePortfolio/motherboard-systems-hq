const gate = await import("../server/execution/execution-approval-gate.mjs");
const commit = await import("../server/execution/cade-governed-commit-adapter.ts");
const push = await import("../server/execution/cade-governed-push-adapter.ts");
const route = await import("../server/routes/governance-execution-route.ts");
const db = await import("../db/client.ts");

if (typeof gate.evaluateExecutionApproval !== "function") {
  throw new Error("approval evaluator unavailable");
}
if (typeof commit.executeGovernedLocalCommit !== "function") {
  throw new Error("commit adapter unavailable");
}
if (typeof push.executeGovernedRemotePush !== "function") {
  throw new Error("push adapter unavailable");
}
if (typeof route.createGovernanceExecutionRouter !== "function") {
  throw new Error("execution router unavailable");
}
if (!db.sqlite) {
  throw new Error("shared sqlite client unavailable");
}

console.log("APPROVAL_EVALUATOR=PASS");
console.log("GOVERNED_COMMIT_ADAPTER=PASS");
console.log("GOVERNED_PUSH_ADAPTER=PASS");
console.log("EXECUTION_ROUTER=PASS");
console.log("SHARED_DB_CLIENT=PASS");
console.log("MJS_COMPOSITION_PREFLIGHT=PASS");
