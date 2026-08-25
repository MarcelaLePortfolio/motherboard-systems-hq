
import express from "express";

import {

  consumeProductionDelegationEntryPoint,

  type ProductionDelegationConsumerInput,

  type ProductionDelegationConsumerResult,

} from "../delegation/production-delegation-consumer";

import type {

  GovernanceDelegationPersistenceFunction,

} from "../delegation/production-delegation-entry-point";

export type GovernanceDelegationRouteBody = {

  delegation_id?: unknown;

  project_id?: unknown;

  package_id?: unknown;

  package_version?: unknown;

  authorization_state?: unknown;

  authorization_timestamp?: unknown;

  delegated_by?: unknown;

};

export type GovernanceDelegationRouteOptions = {

  create_governance_delegation?: GovernanceDelegationPersistenceFunction;

};

export type GovernanceDelegationRouteRequest = ProductionDelegationConsumerInput;

export type GovernanceDelegationRouteResult =

  | {

      ok: true;

      route: "governance_delegation_route";

      delegation: Extract<ProductionDelegationConsumerResult, { ok: true }>;

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

      route: "governance_delegation_route";

      delegation?: ProductionDelegationConsumerResult;

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

export function buildGovernanceDelegationRouteRequest(

  body: GovernanceDelegationRouteBody = {},

  options: GovernanceDelegationRouteOptions = {},

): GovernanceDelegationRouteRequest {

  return {

    delegation_id: normalizeText(body.delegation_id),

    project_id: normalizeText(body.project_id),

    package_id: normalizeText(body.package_id),

    package_version: normalizePackageVersion(body.package_version),

    authorization_state: normalizeText(body.authorization_state),

    authorization_timestamp: normalizeOptionalText(body.authorization_timestamp),

    delegated_by: normalizeText(body.delegated_by),

    create_governance_delegation: options.create_governance_delegation,

  };

}

export function handleGovernanceDelegationRouteRequest(

  body: GovernanceDelegationRouteBody = {},

  options: GovernanceDelegationRouteOptions = {},

): GovernanceDelegationRouteResult {

  const delegationResult = consumeProductionDelegationEntryPoint(

    buildGovernanceDelegationRouteRequest(body, options),

  );

  if (!delegationResult.ok) {

    return {

      ok: false,

      route: "governance_delegation_route",

      delegation: delegationResult,

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

        "Governance Delegation route failed closed because the production Delegation consumer rejected the request.",

      ],

    };

  }

  return {

    ok: true,

    route: "governance_delegation_route",

    delegation: delegationResult,

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

      "Governance Delegation route invoked the production Delegation consumer without scheduler, worker, orchestration, routing, assignment, lifecycle transition, execution, downstream governance, or new authority.",

    ],

  };

}

export function createGovernanceDelegationRouter(

  options: GovernanceDelegationRouteOptions = {},

): express.Router {

  const router = express.Router();

  router.post("/api/governance/delegation", (req, res) => {

    const result = handleGovernanceDelegationRouteRequest(

      req.body || {},

      options,

    );

    return res.status(result.ok ? 200 : 400).json(result);

  });

  return router;

}

export default createGovernanceDelegationRouter();

