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
