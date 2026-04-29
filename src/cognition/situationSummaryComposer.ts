/**
 * TEMP SAFE PATCH:
 * Stabilizes required governanceCognitionState field without refactor
 */

export type SituationSummary = {
  stabilityState: any;
  executionRiskState: any;
  cognitionState: any;
  signalCoherenceState: any;
  operatorAttentionState: any;
  summaryLines: string[];

  // SAFE ADDITION TO SATISFY TS
  governanceCognitionState: "unknown";
};

export {};
