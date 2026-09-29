import Database from "better-sqlite3";
import { strict as assert } from "node:assert";

import { createMissionReadRepository } from "./mission-read-repository";
import { assembleMissionReadModel } from "./mission-read-model-assembler";

const db = new Database("db/main.db", { readonly: true });

async function main(): Promise<void> {
  try {
    const repository = createMissionReadRepository(db);

    const packageRow = db
      .prepare(
        "SELECT project_id, package_id, package_version FROM governance_packages LIMIT 1",
      )
      .get() as
        | {
            project_id?: string;
            package_id?: string;
            package_version?: number;
          }
        | undefined;

    if (!packageRow?.package_id) {
      console.log("No governance packages exist; integration test skipped.");
      return;
    }

    const assemblyInput = await repository.loadMission({
      project_id: packageRow.project_id,
      package_id: packageRow.package_id,
      package_version: packageRow.package_version,
    });

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
