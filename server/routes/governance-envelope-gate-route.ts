
import express from "express";

import {

  consumeProductionEnvelopeGateEntryPoint,

  type ProductionEnvelopeGateConsumerInput,

  type ProductionEnvelopeGateConsumerResult,

} from "../gate/production-envelope-gate-consumer.js";

import type {

  GovernanceEnvelopeGatePersistenceFunction,

} from "../gate/production-envelope-gate-entry-point.js";

export type GovernanceEnvelopeGateRouteBody = {

  envelope_gate_id?: unknown;

  package_id?: unknown;

  package_version?: unknown;

  delegation_id?: unknown;

  validation_result_id?: unknown;

  gate_status?: unknown;

  gate_reason?: unknown;

  gate_decision_timestamp?: unknown;

};

export type GovernanceEnvelopeGateRouteOptions = {

  create_governance_envelope_gate?: GovernanceEnvelopeGatePersistenceFunction;

};

export type GovernanceEnvelopeGateRouteRequest = ProductionEnvelopeGateConsumerInput;

export type GovernanceEnvelopeGateRouteResult =

  | {

      ok: true;

      route: "governance_envelope_gate_route";

      envelope_gate: Extract<ProductionEnvelopeGateConsumerResult, { ok: true }>;

      endpoint_authorized: true;

      scheduler_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      routing_authorized: false;

      assignment_authorized: false;

      lifecycle_transition_authorized: false;

      execution_authorized: false;

      envelope_creation_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    }

  | {

      ok: false;

      route: "governance_envelope_gate_route";

      envelope_gate?: ProductionEnvelopeGateConsumerResult;

      endpoint_authorized: true;

      scheduler_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      routing_authorized: false;

      assignment_authorized: false;

      lifecycle_transition_authorized: false;

      execution_authorized: false;

      envelope_creation_authorized: false;

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

export function buildGovernanceEnvelopeGateRouteRequest(

  body: GovernanceEnvelopeGateRouteBody = {},

  options: GovernanceEnvelopeGateRouteOptions = {},

): GovernanceEnvelopeGateRouteRequest {

  return {

    envelope_gate_id: normalizeText(body.envelope_gate_id),

    package_id: normalizeText(body.package_id),

    package_version: normalizePackageVersion(body.package_version),

    delegation_id: normalizeText(body.delegation_id),

    validation_result_id: normalizeText(body.validation_result_id),

    gate_status: normalizeText(body.gate_status),

    gate_reason: normalizeOptionalText(body.gate_reason),

    gate_decision_timestamp: normalizeOptionalText(body.gate_decision_timestamp),

    create_governance_envelope_gate: options.create_governance_envelope_gate,

  };

}

export function handleGovernanceEnvelopeGateRouteRequest(

  body: GovernanceEnvelopeGateRouteBody = {},

  options: GovernanceEnvelopeGateRouteOptions = {},

): GovernanceEnvelopeGateRouteResult {

  const envelopeGateResult = consumeProductionEnvelopeGateEntryPoint(

    buildGovernanceEnvelopeGateRouteRequest(body, options),

  );

  if (!envelopeGateResult.ok) {

    return {

      ok: false,

      route: "governance_envelope_gate_route",

      envelope_gate: envelopeGateResult,

      endpoint_authorized: true,

      scheduler_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      routing_authorized: false,

      assignment_authorized: false,

      lifecycle_transition_authorized: false,

      execution_authorized: false,

      envelope_creation_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Governance Envelope Gate route failed closed because the production Envelope Gate consumer rejected the request.",

      ],

    };

  }

  return {

    ok: true,

    route: "governance_envelope_gate_route",

    envelope_gate: envelopeGateResult,

    endpoint_authorized: true,

    scheduler_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    routing_authorized: false,

    assignment_authorized: false,

    lifecycle_transition_authorized: false,

    execution_authorized: false,

    envelope_creation_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Governance Envelope Gate route invoked the production Envelope Gate consumer without scheduler, worker, orchestration, routing, assignment, lifecycle transition, execution, Envelope creation, or new authority.",

    ],

  };

}

export function createGovernanceEnvelopeGateRouter(

  options: GovernanceEnvelopeGateRouteOptions = {},

): express.Router {

  const router = express.Router();

  router.post("/api/governance/envelope-gate", (req, res) => {

    const result = handleGovernanceEnvelopeGateRouteRequest(

      req.body || {},

      options,

    );

    return res.status(result.ok ? 200 : 400).json(result);

  });

  return router;

}

export default createGovernanceEnvelopeGateRouter();

