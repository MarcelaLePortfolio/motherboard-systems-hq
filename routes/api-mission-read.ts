import express from "express";
import Database from "better-sqlite3";

import { createMissionReadRepository } from "../db/mission-read-repository";
import { assembleMissionReadModel } from "../db/mission-read-model-assembler";
import { getOperationalPackageForProject } from "../db/operational-package-authority";

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
  "/api/mission-read/:projectId",
  async (req, res) => {
    try {
      const projectId = req.params.projectId?.trim();

      if (!projectId) {
        return res.status(400).json({
          ok: false,
          error: "Missing projectId.",
        });
      }

      const authority =
        getOperationalPackageForProject(db, projectId);

      if (!authority) {
        return res.status(404).json({
          ok: false,
          error: "No active operational mission for project.",
        });
      }

      if (authority.project_id !== projectId) {
        return res.status(409).json({
          ok: false,
          error: "Operational Package Authority project mismatch.",
        });
      }

      const repository = createMissionReadRepository(db);

      const mission = await repository.loadMission({
        project_id: authority.project_id,
        package_id: authority.package_id,
        package_version: authority.package_version,
      });

      if (!mission) {
        return res.status(409).json({
          ok: false,
          error: "Operational mission projection is missing or mismatched.",
        });
      }

      if (
        mission.project_id !== authority.project_id ||
        mission.package_id !== authority.package_id ||
        mission.package_version !== authority.package_version
      ) {
        return res.status(409).json({
          ok: false,
          error: "Operational mission identity mismatch.",
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
