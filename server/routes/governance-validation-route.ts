import express from "express";

import {
  consumeProductionValidationEntryPoint,
  type GovernanceValidationSemanticAnalysisFunction,
  type ProductionValidationConsumerInput,
  type ProductionValidationConsumerResult,
} from "../validation/production-validation-consumer.js";

import type {
  GovernanceValidationDelegationLoader,
} from "../../db/governance-validation-read-repository.js";

import type {
  GovernanceValidationPersistenceFunction,
} from "../validation/production-validation-entry-point.js";

export type GovernanceValidationRouteBody = {
  validation_result_id?: unknown;
  package_id?: unknown;
  package_version?: unknown;
  delegation_id?: unknown;
  validation_timestamp?: unknown;
};

export type GovernanceValidationRouteOptions = {
  create_governance_validation_result?: GovernanceValidationPersistenceFunction;
  load_exact_governance_delegation?: GovernanceValidationDelegationLoader;
  analyze_governance_validation_semantics?: GovernanceValidationSemanticAnalysisFunction;
  database_path?: string;
};

export type GovernanceValidationRouteRequest = ProductionValidationConsumerInput;

export type GovernanceValidationRouteResult =
  | {
      ok: true;
      route: "governance_validation_route";
      validation: Extract<ProductionValidationConsumerResult, { ok: true }>;
      endpoint_authorized: true;
      scheduler_authorized: false;
      worker_claim_authorized: false;
      orchestration_authorized: false;
      routing_authorized: false;
      assignment_authorized: false;
      lifecycle_transition_authorized: false;
      execution_authorized: false;
      downstream_governance_authorized: false;
      new_authority_introduced: false;
      findings: string[];
    }
  | {
      ok: false;
      route: "governance_validation_route";
      validation?: ProductionValidationConsumerResult;
      endpoint_authorized: true;
      scheduler_authorized: false;
      worker_claim_authorized: false;
      orchestration_authorized: false;
      routing_authorized: false;
      assignment_authorized: false;
      lifecycle_transition_authorized: false;
      execution_authorized: false;
      downstream_governance_authorized: false;
      new_authority_introduced: false;
      findings: string[];
    };

function normalizeText(value: unknown): string {
  return typeof value === "string" ? value : "";
}

function normalizeOptionalText(value: unknown): string | null {
  return typeof value === "string" && value.length > 0 ? value : null;
}

function normalizePackageVersion(value: unknown): number {
  return typeof value === "number" && Number.isInteger(value) ? value : 0;
}

export function buildGovernanceValidationRouteRequest(
  body: GovernanceValidationRouteBody = {},
  options: GovernanceValidationRouteOptions = {},
): GovernanceValidationRouteRequest {
  return {
    validation_result_id: normalizeText(body.validation_result_id),
    package_id: normalizeText(body.package_id),
    package_version: normalizePackageVersion(body.package_version),
    delegation_id: normalizeText(body.delegation_id),
    validation_timestamp: normalizeOptionalText(body.validation_timestamp),
    create_governance_validation_result:
      options.create_governance_validation_result,
    load_exact_governance_delegation:
      options.load_exact_governance_delegation,
    analyze_governance_validation_semantics:
      options.analyze_governance_validation_semantics,
    database_path: options.database_path,
  };
}

export async function handleGovernanceValidationRouteRequest(
  body: GovernanceValidationRouteBody = {},
  options: GovernanceValidationRouteOptions = {},
): Promise<GovernanceValidationRouteResult> {
  const validationResult = await consumeProductionValidationEntryPoint(
    buildGovernanceValidationRouteRequest(body, options),
  );

  if (!validationResult.ok) {
    return {
      ok: false,
      route: "governance_validation_route",
      validation: validationResult,
      endpoint_authorized: true,
      scheduler_authorized: false,
      worker_claim_authorized: false,
      orchestration_authorized: false,
      routing_authorized: false,
      assignment_authorized: false,
      lifecycle_transition_authorized: false,
      execution_authorized: false,
      downstream_governance_authorized: false,
      new_authority_introduced: false,
      findings: [
        "Governance Validation route failed closed because the production Validation consumer rejected the request.",
      ],
    };
  }

  return {
    ok: true,
    route: "governance_validation_route",
    validation: validationResult,
    endpoint_authorized: true,
    scheduler_authorized: false,
    worker_claim_authorized: false,
    orchestration_authorized: false,
    routing_authorized: false,
    assignment_authorized: false,
    lifecycle_transition_authorized: false,
    execution_authorized: false,
    downstream_governance_authorized: false,
    new_authority_introduced: false,
    findings: [
      "Governance Validation route invoked semantic Validation without scheduler, worker, orchestration, routing, assignment, lifecycle transition, execution, downstream governance, or new authority.",
    ],
  };
}

export function createGovernanceValidationRouter(
  options: GovernanceValidationRouteOptions = {},
): express.Router {
  const router = express.Router();

  router.post("/api/governance/validation", async (req, res) => {
    const result = await handleGovernanceValidationRouteRequest(
      req.body || {},
      options,
    );

    return res.status(result.ok ? 200 : 400).json(result);
  });

  return router;
}

export default createGovernanceValidationRouter();
