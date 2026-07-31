export type ExecutivePackageKind = "living_draft";

export type ExecutivePackageStatus = "needs_review";

export interface ExecutivePackageReadModel {
  id: string;
  kind: ExecutivePackageKind;
  title: string;
  summary: string;
  status: ExecutivePackageStatus;
  source_status: string;
  project_id: string;
  conversation_id: string | null;
  created_at: string;
  updated_at: string;
}

export interface ExecutivePackageReadCollection {
  project_id: string;
  packages: ExecutivePackageReadModel[];
}

interface PackageReadCollectionSuccessResponse {
  ok: true;
  package_collection: ExecutivePackageReadCollection;
}

interface PackageReadDetailSuccessResponse {
  ok: true;
  package: ExecutivePackageReadModel;
}

interface PackageReadErrorResponse {
  ok: false;
  error: string;
}

type PackageReadCollectionResponse =
  | PackageReadCollectionSuccessResponse
  | PackageReadErrorResponse;

type PackageReadDetailResponse =
  | PackageReadDetailSuccessResponse
  | PackageReadErrorResponse;

function requireIdentifier(
  value: string,
  name: string,
): string {
  const normalized = value.trim();

  if (!normalized) {
    throw new Error(`${name} is required.`);
  }

  return normalized;
}

async function parseResponse<T>(
  response: Response,
  fallbackMessage: string,
): Promise<T> {
  let payload: unknown;

  try {
    payload = await response.json();
  } catch {
    throw new Error(fallbackMessage);
  }

  if (!response.ok) {
    const error = payload as Partial<PackageReadErrorResponse>;

    throw new Error(
      typeof error.error === "string" && error.error.trim()
        ? error.error
        : fallbackMessage,
    );
  }

  return payload as T;
}

export async function getPackageReadCollection(
  projectId: string,
): Promise<ExecutivePackageReadCollection> {
  const normalizedProjectId =
    requireIdentifier(projectId, "projectId");

  const response = await fetch(
    `/api/package-read?project_id=${encodeURIComponent(
      normalizedProjectId,
    )}`,
    {
      headers: {
        Accept: "application/json",
      },
    },
  );

  const payload =
    await parseResponse<PackageReadCollectionResponse>(
      response,
      "Unable to load Package collection.",
    );

  if (!payload.ok) {
    throw new Error(payload.error);
  }

  return payload.package_collection;
}

export async function getPackageReadDetail(
  projectId: string,
  draftPackageId: string,
): Promise<ExecutivePackageReadModel> {
  const normalizedProjectId =
    requireIdentifier(projectId, "projectId");

  const normalizedDraftPackageId =
    requireIdentifier(
      draftPackageId,
      "draftPackageId",
    );

  const response = await fetch(
    `/api/package-read/${encodeURIComponent(
      normalizedDraftPackageId,
    )}?project_id=${encodeURIComponent(
      normalizedProjectId,
    )}`,
    {
      headers: {
        Accept: "application/json",
      },
    },
  );

  const payload =
    await parseResponse<PackageReadDetailResponse>(
      response,
      "Unable to load Package details.",
    );

  if (!payload.ok) {
    throw new Error(payload.error);
  }

  return payload.package;
}
