import Database from "better-sqlite3";
import { createMissionReadRepository } from "../db/mission-read-repository";
import { assembleMissionReadModel } from "../db/mission-read-model-assembler";

async function main(): Promise<void> {
  const db = new Database("db/main.db", { readonly: true });

  try {
    const repository = createMissionReadRepository(db);
    const input = await repository.loadMission("corridor-smoke");

    if (!input) {
      throw new Error("corridor-smoke mission not found");
    }

    const mission = assembleMissionReadModel(input);

    console.log(JSON.stringify(mission, null, 2));

    if (mission.stage !== "ENVELOPE_CREATED") {
      throw new Error(`Unexpected live stage: ${mission.stage}`);
    }

    if (mission.owner !== "GOVERNANCE") {
      throw new Error(`Unexpected live owner: ${mission.owner}`);
    }

    if (mission.health !== "HEALTHY") {
      throw new Error(`Unexpected live health: ${mission.health}`);
    }
  } finally {
    db.close();
  }
}

void main();
