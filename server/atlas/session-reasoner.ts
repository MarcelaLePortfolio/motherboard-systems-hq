
import { EventSession } from "./session-cluster";

/**

 * Converts raw sessions into meaningful "intent blocks"

 */

export function interpretSessions(sessions: EventSession[]) {

  return sessions.map((s, index) => {

    const duration = s.endTime - s.startTime;

    const actions = s.events.map(e => e.action);

    const files = s.events

      .map(e => e.affectedFiles?.[0])

      .filter(Boolean);

    const uniqueActions = new Set(actions).size;

    return {

      sessionId: s.id,

      index,

      durationMs: duration,

      eventCount: s.events.length,

      dominantAction: s.dominantAction,

      dominantFile: s.dominantFile,

      complexityScore: uniqueActions,

      summary: `Session with ${s.events.length} events focused on ${s.dominantAction}`

    };

  });

}

