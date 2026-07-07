
import express from "express";

import {

  consumeProductionEnvelopeEntryPoint,

  type ProductionEnvelopeConsumerInput,

  type ProductionEnvelopeConsumerResult,

} from "../envelope/production-envelope-consumer.js";

import type {

  GovernanceEnvelopePersistenceFunction,

} from "../envelope/production-envelope-entry-point.js";

export type GovernanceEnvelopeRouteBody = {

  envelope_id?: unknown;

  package_id?: unknown;

  package_version?: unknown;

  delegation_id?: unknown;

  validation_result_id?: unknown;

  envelope_gate_id?: unknown;

  validation_status?: unknown;

  required_capabilities?: unknown;

  operational_corridor?: unknown;

  lifecycle_state?: unknown;

};

export type GovernanceEnvelopeRouteOptions = {

  create_governance_envelope?: GovernanceEnvelopePersistenceFunction;

};

export type GovernanceEnvelopeRouteRequest = ProductionEnvelopeConsumerInput;

export type GovernanceEnvelopeRouteResult =

  | {

      ok: true;

      route: "governance_envelope_route";

      envelope: Extract<ProductionEnvelopeConsumerResult, { ok: true }>;

      endpoint_authorized: true;

      scheduler_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      routing_authorized: false;

      assignment_authorized: false;

      lifecycle_transition_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    }

  | {

      ok: false;

      route: "governance_envelope_route";

      envelope?: ProductionEnvelopeConsumerResult;

      endpoint_authorized: true;

      scheduler_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      routing_authorized: false;

      assignment_authorized: false;

      lifecycle_transition_authorized: false;

      execution_authorized: false;

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

export function buildGovernanceEnvelopeRouteRequest(

  body: GovernanceEnvelopeRouteBody = {},

  options: GovernanceEnvelopeRouteOptions = {},

): GovernanceEnvelopeRouteRequest {

  return {

    envelope_id: normalizeText(body.envelope_id),

    package_id: normalizeText(body.package_id),

    package_version: normalizePackageVersion(body.package_version),

    delegation_id: normalizeText(body.delegation_id),

    validation_result_id: normalizeText(body.validation_result_id),

    envelope_gate_id: normalizeText(body.envelope_gate_id),

    validation_status: normalizeText(body.validation_status),

    required_capabilities: normalizeOptionalText(body.required_capabilities),

    operational_corridor: normalizeOptionalText(body.operational_corridor),

    lifecycle_state: normalizeText(body.lifecycle_state),

    create_governance_envelope: options.create_governance_envelope,

  };

}

export function handleGovernanceEnvelopeRouteRequest(

  body: GovernanceEnvelopeRouteBody = {},

  options: GovernanceEnvelopeRouteOptions = {},

): GovernanceEnvelopeRouteResult {

  const envelopeResult = consumeProductionEnvelopeEntryPoint(

    buildGovernanceEnvelopeRouteRequest(body, options),

  );

  if (!envelopeResult.ok) {

    return {

      ok: false,

      route: "governance_envelope_route",

      envelope: envelopeResult,

      endpoint_authorized: true,

      scheduler_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      routing_authorized: false,

      assignment_authorized: false,

      lifecycle_transition_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Governance Envelope route failed closed because the production Envelope consumer rejected the request.",

      ],

    };

  }

  return {

    ok: true,

    route: "governance_envelope_route",

    envelope: envelopeResult,

    endpoint_authorized: true,

    scheduler_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    routing_authorized: false,

    assignment_authorized: false,

    lifecycle_transition_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Governance Envelope route invoked the production Envelope consumer without scheduler, worker, orchestration, routing, assignment, lifecycle transition, execution, or new authority.",

    ],

  };

}

export function createGovernanceEnvelopeRouter(

  options: GovernanceEnvelopeRouteOptions = {},

): express.Router {

  const router = express.Router();

  router.post("/api/governance/envelope", (req, res) => {

    const result = handleGovernanceEnvelopeRouteRequest(

      req.body || {},

      options,

    );

    return res.status(result.ok ? 200 : 400).json(result);

  });

  return router;

}

export default createGovernanceEnvelopeRouter();

