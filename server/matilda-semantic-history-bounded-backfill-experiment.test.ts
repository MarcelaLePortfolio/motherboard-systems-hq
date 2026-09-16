import assert from "node:assert/strict";
import test from "node:test";

type Turn = {
  turnId: string;
  createdAt: string;
  eligible: boolean;
};

type Cursor = {
  createdAt: string;
  turnId: string;
};

type Result = {
  selected: Turn[];
  scanned: Turn[];
  batchCount: number;
};

const TARGET = 20;

function compareDesc(a: Turn, b: Turn): number {
  const time = b.createdAt.localeCompare(a.createdAt);
  return time !== 0 ? time : b.turnId.localeCompare(a.turnId);
}

function beforeCursor(turn: Turn, cursor: Cursor): boolean {
  return (
    turn.createdAt < cursor.createdAt ||
    (turn.createdAt === cursor.createdAt &&
      turn.turnId < cursor.turnId)
  );
}

function backfill(
  source: readonly Turn[],
  batchSize: number,
  scanCeiling: number,
): Result {
  const ordered = [...source].sort(compareDesc);
  const scanned: Turn[] = [];
  const selected: Turn[] = [];
  let cursor: Cursor | null = null;
  let batchCount = 0;

  while (
    selected.length < TARGET &&
    scanned.length < scanCeiling
  ) {
    const remaining = scanCeiling - scanned.length;
    const size = Math.min(batchSize, remaining);

    const available = cursor
      ? ordered.filter((turn) => beforeCursor(turn, cursor!))
      : ordered;

    const batch = available.slice(0, size);

    if (batch.length === 0) break;

    batchCount += 1;
    scanned.push(...batch);

    for (const turn of batch) {
      if (turn.eligible && selected.length < TARGET) {
        selected.push(turn);
      }
    }

    const oldest = batch[batch.length - 1];
    cursor = {
      createdAt: oldest.createdAt,
      turnId: oldest.turnId,
    };
  }

  return {
    selected: [...selected].reverse(),
    scanned,
    batchCount,
  };
}

function makeFixture(
  eligibility: (index: number) => boolean,
  duplicateTimestamps = false,
): Turn[] {
  return Array.from({ length: 100 }, (_, offset) => {
    const index = offset + 1;

    const second = duplicateTimestamps
      ? Math.floor((index - 1) / 2)
      : index - 1;

    return {
      turnId: `turn-${String(index).padStart(3, "0")}`,
      createdAt: `2026-09-16T00:${String(
        Math.floor(second / 60),
      ).padStart(2, "0")}:${String(second % 60).padStart(
        2,
        "0",
      )}.000Z`,
      eligible: eligibility(index),
    };
  });
}

const distributions = {
  recent_clustered: makeFixture(
    (index) => index <= 80,
  ),
  interleaved: makeFixture(
    (index) => index % 2 === 0,
  ),
  heavy_recent: makeFixture(
    (index) => index <= 60,
  ),
  duplicate_created_at: makeFixture(
    (index) => index % 2 === 0,
    true,
  ),
};

test(
  "characterizes bounded eligibility backfill across batch and scan bounds",
  () => {
    const batchSizes = [10, 20, 25];
    const scanCeilings = [25, 50, 75, 100];

    for (const [distribution, fixture] of Object.entries(
      distributions,
    )) {
      for (const batchSize of batchSizes) {
        for (const scanCeiling of scanCeilings) {
          const result = backfill(
            fixture,
            batchSize,
            scanCeiling,
          );

          const scannedIds = result.scanned.map(
            (turn) => turn.turnId,
          );

          assert.equal(
            new Set(scannedIds).size,
            scannedIds.length,
            `${distribution}: cursor must not duplicate turns`,
          );

          const expectedScanOrder = [...fixture]
            .sort(compareDesc)
            .slice(0, result.scanned.length)
            .map((turn) => turn.turnId);

          assert.deepEqual(
            scannedIds,
            expectedScanOrder,
            `${distribution}: cursor must not skip turns`,
          );

          const selectedIds = result.selected.map(
            (turn) => turn.turnId,
          );

          const chronologicalSelected = [
            ...result.selected,
          ].sort((a, b) => -compareDesc(a, b));

          assert.deepEqual(
            selectedIds,
            chronologicalSelected.map(
              (turn) => turn.turnId,
            ),
            `${distribution}: selected history must be chronological`,
          );

          assert.ok(
            result.scanned.length <= scanCeiling,
            `${distribution}: hard scan ceiling must hold`,
          );

          const eligibleWithinCeiling = [...fixture]
            .sort(compareDesc)
            .slice(0, scanCeiling)
            .filter((turn) => turn.eligible).length;

          if (eligibleWithinCeiling >= TARGET) {
            assert.equal(
              result.selected.length,
              TARGET,
              `${distribution}: sufficient eligible history should reach target`,
            );
          } else {
            assert.equal(
              result.selected.length,
              eligibleWithinCeiling,
              `${distribution}: insufficient eligible history must stop bounded`,
            );
          }

          console.log(
            [
              `DISTRIBUTION=${distribution}`,
              `BATCH=${batchSize}`,
              `CEILING=${scanCeiling}`,
              `SCANNED=${result.scanned.length}`,
              `SELECTED=${result.selected.length}`,
              `BATCHES=${result.batchCount}`,
            ].join(" "),
          );
        }
      }
    }

    console.log("BOUNDED_BACKFILL_EXPERIMENT=PASS");
    console.log("COMPOSITE_CURSOR_DUPLICATES=NONE");
    console.log("COMPOSITE_CURSOR_SKIPS=NONE");
    console.log("PRODUCTION_BOUND_ESTABLISHED=NO");
    console.log("OLLAMA_INVOCATION=NO");
  },
);
