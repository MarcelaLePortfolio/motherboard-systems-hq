/**
 * Phase 100.1 — Cognition Contracts
 *
 * Purpose:
 * Establish hard contracts for cognition outputs to prevent drift,
 * enforce deterministic structure, and prepare invariant validation.
 *
 * Rules:
 * - Cognition layer only
 * - No reducers
 * - No wiring
 * - No runtime behavior changes
 * - Deterministic typing only
 */

export type CognitionConfidence = "LOW" | "MEDIUM" | "HIGH";

export type GovernanceStatus =
  | "PASS"
  | "WARN"
  | "FAIL";

export type GuidanceCategory =
  | "ALERT"
  | "INFO"
  | "SUGGESTION";

export interface SituationSummaryContract {
  summary: string;
  confidence: CognitionConfidence;
  signals: string[];
  generated_at: string;
}

export interface OperatorGuidanceContract {
  guidance_id: string;
  category: GuidanceCategory;
  confidence: CognitionConfidence;
  message: string;
  related_signals: string[];
}

export interface GovernanceCognitionContract {
  domain: string;
  invariant: string;
  status: GovernanceStatus;
  evaluated_at: string;
}

export interface CognitionContractEnvelope {
  situation?: SituationSummaryContract;
  guidance?: OperatorGuidanceContract[];
  governance?: GovernanceCognitionContract[];
}

export const COGNITION_CONTRACT_VERSION = "100.1";
