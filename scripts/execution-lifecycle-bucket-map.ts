
import { execSync } from "child_process";

console.log("EXECUTION LIFECYCLE BUCKET MAP");

const raw = execSync(`rg "execution_authorized" -n .`, {

  encoding: "utf8"

});

const lines = raw.split("\n").filter(Boolean);

const buckets: Record<string, number> = {

  gate: 0,

  lifecycle: 0,

  scheduler: 0,

  envelope: 0,

  ellis: 0,

  other: 0

};

for (const line of lines) {

  const file = line.split(":")[0];

  if (file.includes("execution-approval-gate")) buckets.gate++;

  else if (file.includes("lifecycle")) buckets.lifecycle++;

  else if (file.includes("scheduler")) buckets.scheduler++;

  else if (file.includes("envelope")) buckets.envelope++;

  else if (file.includes("ellis")) buckets.ellis++;

  else buckets.other++;

}

console.log(buckets);

