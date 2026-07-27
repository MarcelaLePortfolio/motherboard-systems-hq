import Database from "better-sqlite3";
import { strict as assert } from "node:assert";

import { createMissionReadRepository } from "./mission-read-repository";
import { assembleMissionReadModel } from "./mission-read-model-assembler";

const db = new Database("db/main.db", { readonly: true });

async function main(): Promise<void> {
  try {
    const repository = createMissionReadRepository(db);

    const packageRow = db
      .prepare("SELECT package_id FROM governance_packages LIMIT 1")
      .get() as { package_id?: string } | undefined;

    if (!packageRow?.package_id) {
      console.log("No governance packages exist; integration test skipped.");
      return;
    }

    const assemblyInput = await repository.loadMission(packageRow.package_id);

    assert.ok(assemblyInput);

    const mission = assembleMissionReadModel(assemblyInput!);

    assert.equal(mission.identity.package_id, packageRow.package_id);
    assert.ok(typeof mission.identity.package_version === "number");
    assert.ok(typeof mission.stage === "string");
    assert.ok(typeof mission.owner === "string");
    assert.ok(typeof mission.health === "string");
    assert.ok(Array.isArray(mission.timeline));

    console.log("Mission Read Model end-to-end integration test passed.");
  } finally {
    db.close();
  }
}

void main();
