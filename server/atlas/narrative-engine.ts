
import { ExecutionEvent } from "../events/execution-event-bus";

import { EventSession } from "./session-cluster";

import { runAtlasIntelligence } from "./atlas-unified-engine";

/**

 * Converts Atlas structured intelligence into human-readable narrative

 */

export function generateNarrative(events: ExecutionEvent[]) {

  const analysis = runAtlasIntelligence(events);

  const sessions = analysis.sessions || [];

  const sessionNarratives = sessions.map((session: EventSession, i: number) => {

    const actions = session.events.map(e => e.action);

    const files = session.events

      .map(e => e.affectedFiles?.[0])

      .filter(Boolean);

    const uniqueActions = new Set(actions);

    const dominant = session.dominantAction;

    const fileFocus = session.dominantFile ?? "multiple system areas";

    return {

      title: `Session ${i + 1}`,

      narrative:

        `During this period, the system executed ${session.events.length} actions ` +

        `primarily focused on "${dominant}". ` +

        `The activity affected ${fileFocus}. ` +

        `Key behaviors included ${Array.from(uniqueActions).join(", ")}. ` +

        `This indicates a concentrated operational phase rather than random execution.`,

      confidence: 0.8

    };

  });

  const globalSummary =

    `Across ${sessions.length} sessions, the system exhibited ` +

    `structured behavior patterns with ${analysis.graph.length} causal events. ` +

    `Recent activity shows ${new Set(events.map(e => e.action)).size} unique action types.`;

  return {

    globalSummary,

    sessions: sessionNarratives

  };

}

