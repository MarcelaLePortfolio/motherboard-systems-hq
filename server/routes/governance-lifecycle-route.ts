
import express from "express";

import {

  consumeProductionLifecycleEntryPoint,

  type OperationalIntakeCreationFunction,

  type ProductionLifecycleConsumerInput,

  type ProductionLifecycleConsumerResult,

} from "../lifecycle/production-lifecycle-consumer.js";

import type {

  GovernanceLifecyclePersistenceFunction,

} from "../../db/governance-lifecycle-composition.js";

export type GovernanceLifecycleRouteBody = {

  envelope_id?: unknown;

  envelope?: ProductionLifecycleConsumerInput["envelope"];

  available_departments?: unknown;

  department_handshake?: ProductionLifecycleConsumerInput["department_handshake"];

  target_lifecycle_state?: ProductionLifecycleConsumerInput["target_lifecycle_state"];

  persisted_at?: unknown;

};

export type GovernanceLifecycleRouteOptions = {

  db?: unknown;

  persist_lifecycle_transition?: GovernanceLifecyclePersistenceFunction;

  create_operational_intake?: OperationalIntakeCreationFunction;

};

export type GovernanceLifecycleRouteRequest = ProductionLifecycleConsumerInput;

export type GovernanceLifecycleRouteResult =

  | {

      ok: true;

      route: "governance_lifecycle_route";

      lifecycle: Extract<ProductionLifecycleConsumerResult, { ok: true }>;

      endpoint_authorized: true;

      scheduler_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      routing_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    }

  | {

      ok: false;

      route: "governance_lifecycle_route";

      lifecycle?: ProductionLifecycleConsumerResult;

      endpoint_authorized: true;

      scheduler_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      routing_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

function normalizeText(value: unknown): string {

  return typeof value === "string" ? value : "";

}

function normalizeTextArray(value: unknown): string[] {

  if (!Array.isArray(value)) {

    return [];

  }

  return value.filter((item): item is string => typeof item === "string");

}

export function buildGovernanceLifecycleRouteRequest(

  body: GovernanceLifecycleRouteBody = {},

  options: GovernanceLifecycleRouteOptions = {},

): GovernanceLifecycleRouteRequest {

  return {

    envelope_id: normalizeText(body.envelope_id),

    envelope: body.envelope,

    available_departments: normalizeTextArray(body.available_departments),

    department_handshake: body.department_handshake,

    target_lifecycle_state: body.target_lifecycle_state,

    persisted_at: normalizeText(body.persisted_at) || undefined,

    db: options.db,

    persist_lifecycle_transition: options.persist_lifecycle_transition,

    create_operational_intake: options.create_operational_intake,

  };

}

export function handleGovernanceLifecycleRouteRequest(

  body: GovernanceLifecycleRouteBody = {},

  options: GovernanceLifecycleRouteOptions = {},

): GovernanceLifecycleRouteResult {

  const lifecycle = consumeProductionLifecycleEntryPoint(

    buildGovernanceLifecycleRouteRequest(body, options),

  );

  if (!lifecycle.ok) {

    return {

      ok: false,

      route: "governance_lifecycle_route",

      lifecycle,

      endpoint_authorized: true,

      scheduler_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      routing_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Governance lifecycle route failed closed because the production lifecycle consumer rejected the request.",

      ],

    };

  }

  return {

    ok: true,

    route: "governance_lifecycle_route",

    lifecycle,

    endpoint_authorized: true,

    scheduler_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    routing_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Governance lifecycle route invoked the production lifecycle consumer without scheduler, worker, orchestration, routing, execution, actor assignment, participation resolution, or new authority.",

    ],

  };

}

export function createGovernanceLifecycleRouter(

  options: GovernanceLifecycleRouteOptions = {},

): express.Router {

  const router = express.Router();

  router.post("/api/governance/lifecycle", (req, res) => {

    const result = handleGovernanceLifecycleRouteRequest(

      req.body || {},

      options,

    );

    return res.status(result.ok ? 200 : 400).json(result);

  });

  return router;

}

export default createGovernanceLifecycleRouter();

