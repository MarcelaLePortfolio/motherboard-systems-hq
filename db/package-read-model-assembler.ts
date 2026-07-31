import type { LivingDraftPackageReadRecord } from "./package-read-repository";
import type {
  ExecutivePackageReadCollection,
  ExecutivePackageReadModel,
} from "./package-read-model-types";

function normalize(value: string | null | undefined): string | null {
  const trimmed = value?.trim();
  return trimmed ? trimmed : null;
}

function requireProjectId(projectId: string): string {
  const normalized = projectId.trim();

  if (!normalized) {
    throw new Error("projectId is required.");
  }

  return normalized;
}

function buildTitle(
  record: LivingDraftPackageReadRecord,
): string {
  return (
    normalize(record.expected_outcome) ??
    normalize(record.current_interpretation) ??
    "Untitled Living Draft Package"
  );
}

function buildSummary(
  record: LivingDraftPackageReadRecord,
): string {
  return (
    normalize(record.current_interpretation) ??
    normalize(record.proposed_work) ??
    "No interpretation summary is currently available."
  );
}

export function assembleLivingDraftPackageReadModel(
  record: LivingDraftPackageReadRecord,
): ExecutivePackageReadModel {
  const projectId = normalize(record.project_id);

  if (!projectId) {
    throw new Error(
      `Living Draft Package "${record.draft_package_id}" has no project_id.`,
    );
  }

  return {
    id: record.draft_package_id,
    kind: "living_draft",
    title: buildTitle(record),
    summary: buildSummary(record),
    status: "needs_review",
    source_status: record.status,
    project_id: projectId,
    conversation_id: normalize(record.conversation_id),
    created_at: record.created_at,
    updated_at: record.updated_at,
  };
}

export function assembleLivingDraftPackageReadCollection(
  projectId: string,
  records: LivingDraftPackageReadRecord[],
): ExecutivePackageReadCollection {
  const normalizedProjectId = requireProjectId(projectId);

  const mismatch = records.find(
    (record) => record.project_id !== normalizedProjectId,
  );

  if (mismatch) {
    throw new Error(
      `Package "${mismatch.draft_package_id}" belongs to project "${mismatch.project_id}".`,
    );
  }

  return {
    project_id: normalizedProjectId,
    packages: records.map(assembleLivingDraftPackageReadModel),
  };
}
