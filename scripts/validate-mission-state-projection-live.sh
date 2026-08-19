#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

cat > /tmp/validate-mission-state-projection-live.ts << 'TS'
import Database from "better-sqlite3";
import { createMissionReadRepository } from "../Projects/motherboard-systems-hq-clean/db/mission-read-repository";
import { assembleMissionReadModel } from "../Projects/motherboard-systems-hq-clean/db/mission-read-model-assembler";

async function main(): Promise<void> {
  const db = new Database(
    "/Users/marcela-dev/Projects/motherboard-systems-hq-clean/db/main.db",
    { readonly: true },
  );

  try {
    const repository = createMissionReadRepository(db);
    const input = await repository.loadMission("corridor-smoke");
    console.log(JSON.stringify(input ? assembleMissionReadModel(input) : null, null, 2));
  } finally {
    db.close();
  }
}

void main();
TS

printf '\n=== TARGETED BACKEND VALIDATION ===\n'
npx tsx db/mission-read-model-assembler.test.ts
npx tsx db/mission-read-repository.test.ts
npx tsx db/mission-read-model.integration.test.ts

printf '\n=== CLIENT BUILD ===\n'
npm run build --prefix client

printf '\n=== LIVE PROJECTION ===\n'
npx tsx /tmp/validate-mission-state-projection-live.ts

printf '\n=== WORKTREE ===\n'
git status --short
