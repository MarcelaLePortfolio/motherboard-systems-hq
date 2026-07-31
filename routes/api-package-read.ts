import express, { type Request, type Response } from "express";

import {
  assembleLivingDraftPackageReadCollection,
  assembleLivingDraftPackageReadModel,
} from "../db/package-read-model-assembler";
import { createPackageReadRepository } from "../db/package-read-repository";

function readProjectId(req: Request): string {
  return typeof req.query.project_id === "string"
    ? req.query.project_id.trim()
    : "";
}

export function createPackageReadRouter(
  databasePath = "db/main.db",
): express.Router {
  const router = express.Router();

  router.get("/api/package-read", (req: Request, res: Response) => {
    const projectId = readProjectId(req);

    if (!projectId) {
      return res.status(400).json({
        ok: false,
        error: "Missing or invalid 'project_id' query parameter.",
      });
    }

    const repository = createPackageReadRepository(databasePath);

    try {
      const records =
        repository.listLivingDraftPackagesByProject(projectId);

      return res.json({
        ok: true,
        package_collection:
          assembleLivingDraftPackageReadCollection(projectId, records),
      });
    } catch (error) {
      console.error("[GET /api/package-read] Error:", error);

      return res.status(500).json({
        ok: false,
        error: "Unable to load Package Read collection.",
      });
    } finally {
      repository.close();
    }
  });

  router.get(
    "/api/package-read/:draftPackageId",
    (req: Request, res: Response) => {
      const projectId = readProjectId(req);
      const draftPackageId = req.params.draftPackageId?.trim();

      if (!projectId) {
        return res.status(400).json({
          ok: false,
          error: "Missing or invalid 'project_id' query parameter.",
        });
      }

      if (!draftPackageId) {
        return res.status(400).json({
          ok: false,
          error: "Missing draftPackageId.",
        });
      }

      const repository = createPackageReadRepository(databasePath);

      try {
        const record = repository.getLivingDraftPackageById(
          projectId,
          draftPackageId,
        );

        if (!record) {
          return res.status(404).json({
            ok: false,
            error: "Living Draft Package not found.",
          });
        }

        return res.json({
          ok: true,
          package: assembleLivingDraftPackageReadModel(record),
        });
      } catch (error) {
        console.error(
          "[GET /api/package-read/:draftPackageId] Error:",
          error,
        );

        return res.status(500).json({
          ok: false,
          error: "Unable to load Package Read detail.",
        });
      } finally {
        repository.close();
      }
    },
  );

  return router;
}

export default createPackageReadRouter();
