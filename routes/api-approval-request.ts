import { Router } from "express";

import {
  createApprovalRequestRepository,
} from "../db/approval-request-repository";

import {
  assembleApprovalRequestReadCollection,
} from "../db/approval-request-model-assembler";

const router = Router();

router.get("/", (req, res) => {
  const projectId =
    typeof req.query.project_id === "string"
      ? req.query.project_id.trim()
      : "";

  if (!projectId) {
    return res.status(400).json({
      error: "project_id is required",
    });
  }

  const repository =
    createApprovalRequestRepository();

  try {
    const sources =
      repository.listPendingCanonicalPackageApprovalsByProject(
        projectId,
      );

    const collection =
      assembleApprovalRequestReadCollection(
        projectId,
        sources,
      );

    return res.json(collection);
  } finally {
    repository.close();
  }
});

export default router;
