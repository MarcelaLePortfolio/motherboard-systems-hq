import express from "express";
import Database from "better-sqlite3";

import { createMissionReadRepository } from "../db/mission-read-repository";
import { assembleMissionReadModel } from "../db/mission-read-model-assembler";

const router = express.Router();

/*
 * Mission Read is part of the governance persistence family.
 * Use the same authoritative database as governance-runtime
 * and the Mission Read integration tests.
 */
const db = new Database("db/main.db", {
  readonly: true,
});

router.get(
  "/api/mission-read/:packageId",
  async (req, res) => {
    try {
      const packageId = req.params.packageId?.trim();

      if (!packageId) {
        return res.status(400).json({
          ok: false,
          error: "Missing packageId.",
        });
      }

      const repository = createMissionReadRepository(db);
      const mission = await repository.loadMission(packageId);

      if (!mission) {
        return res.status(404).json({
          ok: false,
          error: "Mission package not found.",
        });
      }

      return res.json({
        ok: true,
        mission: assembleMissionReadModel(mission),
      });
    } catch (error) {
      console.error("[Mission Read API]", error);

      return res.status(500).json({
        ok: false,
        error: "Unable to assemble Mission Read Model.",
      });
    }
  },
);

export default router;
