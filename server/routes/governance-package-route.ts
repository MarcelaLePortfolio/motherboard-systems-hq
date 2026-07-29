
import express from "express";

import {

  consumeProductionPackageEntryPoint,

  type ProductionPackageConsumerInput,

  type ProductionPackageConsumerResult,

} from "../package/production-package-consumer.js";

import type {

  GovernancePackagePersistenceFunction,

} from "../package/production-package-entry-point.js";

export type GovernancePackageRouteBody = {

  package_id?: unknown;

  package_version?: unknown;

  project_id?: unknown;

  conversation_id?: unknown;

  requested_outcome?: unknown;

  scope?: unknown;

  containment?: unknown;

  constraints?: unknown;

  success_criteria?: unknown;

  context?: unknown;

  style_presentation_intent?: unknown;

  exclusions?: unknown;

};

export type GovernancePackageRouteOptions = {

  create_governance_package?: GovernancePackagePersistenceFunction;

};

export type GovernancePackageRouteRequest = ProductionPackageConsumerInput;

export type GovernancePackageRouteResult =

  | {

      ok: true;

      route: "governance_package_route";

      package: Extract<ProductionPackageConsumerResult, { ok: true }>;

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

      route: "governance_package_route";

      package?: ProductionPackageConsumerResult;

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

export function buildGovernancePackageRouteRequest(

  body: GovernancePackageRouteBody = {},

  options: GovernancePackageRouteOptions = {},

): GovernancePackageRouteRequest {

  return {

    package_id: normalizeText(body.package_id),

    package_version: normalizePackageVersion(body.package_version),

    project_id: normalizeText(body.project_id),

    conversation_id: normalizeText(body.conversation_id),

    requested_outcome: normalizeText(body.requested_outcome),

    scope: normalizeText(body.scope),

    containment: normalizeText(body.containment),

    constraints: normalizeText(body.constraints),

    success_criteria: normalizeText(body.success_criteria),

    context: normalizeOptionalText(body.context),

    style_presentation_intent: normalizeOptionalText(

      body.style_presentation_intent,

    ),

    exclusions: normalizeOptionalText(body.exclusions),

    create_governance_package: options.create_governance_package,

  };

}

export function handleGovernancePackageRouteRequest(

  body: GovernancePackageRouteBody = {},

  options: GovernancePackageRouteOptions = {},

): GovernancePackageRouteResult {

  const packageResult = consumeProductionPackageEntryPoint(

    buildGovernancePackageRouteRequest(body, options),

  );

  if (!packageResult.ok) {

    return {

      ok: false,

      route: "governance_package_route",

      package: packageResult,

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

        "Governance Package route failed closed because the production Package consumer rejected the request.",

      ],

    };

  }

  return {

    ok: true,

    route: "governance_package_route",

    package: packageResult,

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

      "Governance Package route invoked the production Package consumer without scheduler, worker, orchestration, routing, assignment, lifecycle transition, execution, downstream governance, or new authority.",

    ],

  };

}

export function createGovernancePackageRouter(

  options: GovernancePackageRouteOptions = {},

): express.Router {

  const router = express.Router();

  router.post("/api/governance/package", (req, res) => {

    const result = handleGovernancePackageRouteRequest(req.body || {}, options);

    return res.status(result.ok ? 200 : 400).json(result);

  });

  return router;

}

export default createGovernancePackageRouter();

