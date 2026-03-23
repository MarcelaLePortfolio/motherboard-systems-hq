/**
 * Phase 100.2 — Cognition Invariants
 *
 * Purpose:
 * Establish invariant guards to ensure cognition contracts
 * cannot drift into invalid or non-deterministic structures.
 *
 * Rules:
 * - Read-only validation only
 * - No runtime mutation
 * - No reducers
 * - No wiring
 * - Pure invariant checks only
 */

import {
  CognitionContractEnvelope,
  CognitionConfidence,
  GovernanceStatus
} from "../contracts/cognition.contracts";

const VALID_CONFIDENCE: CognitionConfidence[] = [
  "LOW",
  "MEDIUM",
  "HIGH"
];

const VALID_GOVERNANCE: GovernanceStatus[] = [
  "PASS",
  "WARN",
  "FAIL"
];

export function invariantConfidence(value: string): boolean {
  return VALID_CONFIDENCE.includes(value as CognitionConfidence);
}

export function invariantGovernanceStatus(value: string): boolean {
  return VALID_GOVERNANCE.includes(value as GovernanceStatus);
}

export function invariantSituationSummary(
  envelope: CognitionContractEnvelope
): boolean {

  if (!envelope.situation) {
    return true;
  }

  if (!envelope.situation.summary) {
    return false;
  }

  if (!invariantConfidence(envelope.situation.confidence)) {
    return false;
  }

  if (!Array.isArray(envelope.situation.signals)) {
    return false;
  }

  return true;
}

export function invariantGovernance(
  envelope: CognitionContractEnvelope
): boolean {

  if (!envelope.governance) {
    return true;
  }

  for (const item of envelope.governance) {

    if (!item.domain) {
      return false;
    }

    if (!item.invariant) {
      return false;
    }

    if (!invariantGovernanceStatus(item.status)) {
      return false;
    }
  }

  return true;
}

export function invariantGuidance(
  envelope: CognitionContractEnvelope
): boolean {

  if (!envelope.guidance) {
    return true;
  }

  for (const item of envelope.guidance) {

    if (!item.guidance_id) {
      return false;
    }

    if (!invariantConfidence(item.confidence)) {
      return false;
    }

    if (!item.message) {
      return false;
    }
  }

  return true;
}

export function cognitionInvariantCheck(
  envelope: CognitionContractEnvelope
): boolean {

  if (!invariantSituationSummary(envelope)) {
    return false;
  }

  if (!invariantGovernance(envelope)) {
    return false;
  }

  if (!invariantGuidance(envelope)) {
    return false;
  }

  return true;
}
