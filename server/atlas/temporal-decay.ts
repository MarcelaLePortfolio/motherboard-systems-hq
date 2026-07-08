
import { ExecutionEvent } from "../events/execution-event-bus";

/**

 * Time decay reduces influence of older events.

 * Recent events dominate reasoning.

 */

export function applyTemporalDecay(

  events: ExecutionEvent[],

  halfLifeMs: number = 1000 * 60 * 10 // 10 minutes default

) {

  const now = Date.now();

  return events.map(event => {

    const age = now - event.timestamp;

    // exponential decay: older = weaker

    const decay = Math.pow(0.5, age / halfLifeMs);

    return {

      ...event,

      temporalWeight: decay

    };

  });

}

