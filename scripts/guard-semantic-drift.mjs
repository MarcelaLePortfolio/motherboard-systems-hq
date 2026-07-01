
import { execSync } from "node:child_process";

const watchedTokens = ["readiness", "completion"];

const allowedPaths = new Set([

  "server/operational/scheduler-runtime-finalization-readiness-completion-boundary.ts",

  "server/operational/scheduler-runtime-finalization-readiness-completion-boundary.test.ts",

  "server/operational/scheduler-runtime-finalization-readiness-completion-entry-point.ts",

  "server/operational/scheduler-runtime-finalization-readiness-completion-entry-point.test.ts",

  "server/operational/production-scheduler-runtime-finalization-readiness-completion-consumer.ts",

  "server/operational/production-scheduler-runtime-finalization-readiness-completion-consumer.test.ts",

  "server/operational/scheduler-runtime-finalization-readiness-completion-authorization-boundary.ts",

  "server/operational/scheduler-runtime-finalization-readiness-completion-authorization-boundary.test.ts",

  "server/operational/scheduler-runtime-finalization-readiness-completion-contract.ts",

  "server/operational/scheduler-runtime-finalization-readiness-completion-contract.test.ts",

  "server/operational/production-scheduler-runtime-finalization-readiness-completion-contract-consumer.ts",

  "server/operational/production-scheduler-runtime-finalization-readiness-completion-contract-consumer.test.ts",

]);

const output = execSync("git ls-files --others --cached --modified --exclude-standard server/operational", {

  encoding: "utf8",

});

const files = output.split("\n").map((line) => line.trim()).filter(Boolean);

const violations = [];

for (const file of files) {

  if (allowedPaths.has(file)) continue;

  const segments = file.split(/[/.\\_-]+/).filter(Boolean);

  const semanticSegments = segments.filter((segment) => watchedTokens.includes(segment));

  const hasRecursiveTriplet = semanticSegments.some((token, index) => {

    const next = semanticSegments[index + 1];

    const third = semanticSegments[index + 2];

    return token && next && third && token === third && token !== next;

  });

  const tokenCounts = semanticSegments.reduce((counts, token) => {

    counts[token] = (counts[token] ?? 0) + 1;

    return counts;

  }, {});

  const hasRepeatedSemanticToken = Object.values(tokenCounts).some((count) => count > 1);

  if (hasRecursiveTriplet || hasRepeatedSemanticToken) {

    violations.push(file);

  }

}

if (violations.length > 0) {

  console.error("Semantic drift guard blocked recursive readiness/completion path growth:");

  for (const violation of violations) console.error(`- ${violation}`);

  console.error("Add an explicit finite-state-machine approval before extending this corridor.");

  process.exit(1);

}

console.log("Semantic drift guard passed.");

