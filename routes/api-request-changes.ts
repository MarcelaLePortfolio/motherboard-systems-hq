import express, {
  type Request,
  type Response,
} from "express";

import {
  createApprovalRequestRepository,
  type ApprovalRequestRepository,
} from "../db/approval-request-repository";
import {
  MatildaConversationWorkflowUnavailableError,
  runMatildaConversationWorkflow,
  type MatildaConversationWorkflowResult,
} from "../server/matilda-chat-workflow";
import {
  validateMatildaUserPackageSemanticsInput,
  type MatildaUserPackageSemanticsInput,
} from "../scripts/utils/ollamaChat";

type RequestChangesWorkflow = (
  input: {
    message: string;
    agent: string;
    project_id: string;
    conversation_id: string;
    userPackageSemantics?: MatildaUserPackageSemanticsInput | null;
    requirePackageSemantics: boolean;
  },
) => Promise<MatildaConversationWorkflowResult>;

export interface RequestChangesDependencies {
  createRepository?: () => ApprovalRequestRepository;
  runWorkflow?: RequestChangesWorkflow;
}

function readRequiredText(
  value: unknown,
): string {
  return typeof value === "string"
    ? value.trim()
    : "";
}

export function createRequestChangesHandler(
  dependencies: RequestChangesDependencies = {},
) {
  const createRepository =
    dependencies.createRepository ??
    (() => createApprovalRequestRepository());

  const runWorkflow =
    dependencies.runWorkflow ??
    runMatildaConversationWorkflow;

  return async function handleRequestChanges(
    req: Request,
    res: Response,
  ) {
    const approvalRequestId = readRequiredText(
      req.body?.approval_request_id,
    );
    const feedback = readRequiredText(
      req.body?.feedback,
    );

    let userPackageSemantics:
      MatildaUserPackageSemanticsInput | null;

    try {
      userPackageSemantics =
        validateMatildaUserPackageSemanticsInput(
          req.body?.user_package_semantics,
        );
    } catch (error) {
      return res.status(400).json({
        ok: false,
        error:
          error instanceof Error
            ? error.message
            : "Malformed explicit user package semantics input.",
      });
    }

    if (!approvalRequestId || !feedback) {
      return res.status(400).json({
        ok: false,
        error:
          "approval_request_id and feedback are required.",
      });
    }

    /*
     * Approval Request identity is currently derived from the
     * pending Living Draft identity. The client supplies only that
     * opaque request identity; it does not supply project or
     * conversation authority.
     */
    const canonicalApprovalRequestPrefix =
      "canonical_package_approval:";

    if (
      !approvalRequestId.startsWith(
        canonicalApprovalRequestPrefix,
      )
    ) {
      return res.status(404).json({
        ok: false,
        error:
          "The requested pending approval is unavailable.",
      });
    }

    const draftPackageId = approvalRequestId
      .slice(canonicalApprovalRequestPrefix.length)
      .trim();

    if (!draftPackageId) {
      return res.status(404).json({
        ok: false,
        error:
          "The requested pending approval is unavailable.",
      });
    }

    const repository = createRepository();

    try {
      /*
       * The client supplies only the opaque Approval Request identity.
       * Resolve project and originating conversation authority entirely
       * from authoritative pending-draft persistence.
       */
      const source =
        repository.getPendingCanonicalPackageApprovalByDraftPackageId(
          draftPackageId,
        );

      if (!source) {
        return res.status(404).json({
          ok: false,
          error:
            "The requested pending approval is unavailable.",
        });
      }

      const conversationId =
        readRequiredText(source.conversation_id);

      if (!conversationId) {
        return res.status(409).json({
          ok: false,
          error:
            "The pending approval has no originating conversation.",
        });
      }

      try {
        const result = await runWorkflow({
          message: feedback,
          agent: "matilda",
          project_id: source.project_id,
          conversation_id: conversationId,
          userPackageSemantics,
          requirePackageSemantics: true,
        });

        return res.status(200).json({
          ok: true,
          route: "request_changes_route",
          result,
          canonical_package_created: false,
          delegation_authorized: false,
          validation_authorized: false,
          envelope_authorized: false,
          execution_authorized: false,
        });
      } catch (error) {
        if (
          error instanceof
          MatildaConversationWorkflowUnavailableError
        ) {
          return res.status(503).json({
            ok: false,
            error: error.message,
            canonical_package_created: false,
            delegation_authorized: false,
            validation_authorized: false,
            envelope_authorized: false,
            execution_authorized: false,
          });
        }

        throw error;
      }
    } finally {
      repository.close();
    }
  };
}

const router = express.Router();

router.post(
  "/api/request-changes",
  createRequestChangesHandler(),
);

export default router;
