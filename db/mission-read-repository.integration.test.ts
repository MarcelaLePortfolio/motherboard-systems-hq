import Database from "better-sqlite3";
import { strict as assert } from "node:assert";
import { createMissionReadRepository } from "./mission-read-repository";

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
      console.log(
        "No governance packages exist; repository integration test skipped.",
      );
      return;
    }

    const mission = await repository.loadMission({
      project_id: packageRow.project_id,
      package_id: packageRow.package_id,
      package_version: packageRow.package_version,
    });

    assert.ok(mission);
    assert.equal(mission.package_id, packageRow.package_id);
    assert.equal(typeof mission.package_version, "number");
    assert.equal(
      mission.project_id === null || typeof mission.project_id === "string",
      true,
    );
    assert.equal(
      mission.conversation_id === null ||
        typeof mission.conversation_id === "string",
      true,
    );
    assert.equal(typeof mission.lifecycle_event_count, "number");

    console.log("Mission Read Repository integration test passed.");
  } finally {
    db.close();
  }
}

void main();
