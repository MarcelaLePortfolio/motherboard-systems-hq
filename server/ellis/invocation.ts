
import {

  evaluateEllisDecision,

  type EllisDecision,

} from "./decision";

export type EllisEnvelopeShape = {

  required_capabilities?: string | string[] | null;

  operational_corridor?: string | null;

};

export type EllisInvocationInput = {

  envelope: EllisEnvelopeShape;

  available_departments?: string[];

  available_actors?: string[];

};

function normalizeCapabilities(

  value: string | string[] | null | undefined,

): string[] {

  if (Array.isArray(value)) {

    return value.map((item) => item.trim()).filter(Boolean);

  }

  return String(value ?? "")

    .split(",")

    .map((item) => item.trim())

    .filter(Boolean);

}

export function invokeEllisFromEnvelope(

  input: EllisInvocationInput,

): EllisDecision {

  return evaluateEllisDecision({

    required_capabilities: normalizeCapabilities(

      input.envelope.required_capabilities,

    ),

    operational_corridor: input.envelope.operational_corridor?.trim() ?? "",

    available_departments: input.available_departments ?? [],

    available_actors: input.available_actors ?? [],

  });

}

