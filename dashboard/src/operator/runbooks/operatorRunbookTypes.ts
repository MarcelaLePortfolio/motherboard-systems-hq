export type RiskLevel =
  | "SAFE"
  | "LOW"
  | "MEDIUM"
  | "HIGH"
  | "CRITICAL";

export type SystemStateClass =
  | "STABLE"
  | "OBSERVE"
  | "INVESTIGATE"
  | "RECOVERY";

export type RunbookStep = {
  id: string;
  description: string;
};

export type Runbook = {
  id: string;
  title: string;
  risk: RiskLevel;
  state: SystemStateClass;
  steps: RunbookStep[];
  continueSafe: boolean;
};
