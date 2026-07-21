export interface ProjectSummary {
  projectId: string;
  displayName: string;
  projectRootPath: string;
  gitRepositoryReference: string | null;
  registrationStatus: string;
  availabilityStatus: string;
  activeContextEligible: boolean;
  createdAt: string;
  updatedAt: string;
  lastOpenedAt: string | null;
}

export interface ActiveContext {
  currentProjectId: string;
  source: string;
  action: string;
  updatedAt: string;
}

export interface ProjectRegistryState {
  activeProjectId: string | null;
  activeProject: ProjectSummary | null;
  activeContext: ActiveContext | null;
  projects: ProjectSummary[];
}
