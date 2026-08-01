import { Router } from "express";

import {
  createApprovalRequestRepository,
} from "../db/approval-request-repository";

import {
  assembleApprovalRequestReadCollection,
} from "../db/approval-request-model-assembler";

export function handleApprovalRequestList(req: any, res: any) {
  const projectId =
    typeof req.query?.project_id === "string"
      ? req.query.project_id.trim()
      : "";

  if (!projectId) {
    return res.status(400).json({
      error: "project_id is required",
    });
  }

  const repository = createApprovalRequestRepository();

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

    return res.status(200).json(collection);
  } finally {
    repository.close();
  }
}

const router = Router();

router.get("/", handleApprovalRequestList);

export default router;
