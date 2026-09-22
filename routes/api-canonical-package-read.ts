import { Router } from "express";
import {
  createCanonicalPackageReadRepository,
} from "../db/canonical-package-read-repository";

const router = Router();

router.get("/api/canonical-packages", (req, res) => {
  const projectId =
    typeof req.query.project_id === "string"
      ? req.query.project_id.trim()
      : "";

  if (!projectId) {
    res.status(400).json({
      error: "Missing or invalid 'project_id' query parameter.",
    });
    return;
  }

  const repository = createCanonicalPackageReadRepository();

  try {
    res.json({
      project_id: projectId,
      packages: repository.listByProject(projectId),
    });
  } catch (error) {
    console.error(
      "[GET /api/canonical-packages] Error:",
      error,
    );

    res.status(500).json({
      error: "Unable to load approved Canonical Packages.",
    });
  } finally {
    repository.close();
  }
});

export default router;
