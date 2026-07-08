
import { ExecutionEvent } from "../events/execution-event-bus";

export type EventSession = {

  id: string;

  startTime: number;

  endTime: number;

  events: ExecutionEvent[];

  dominantAction: string;

  dominantFile?: string;

};

/**

 * Groups events into sessions based on:

 * - time proximity (temporal decay logic)

 * - file continuity

 * - action repetition

 */

export function clusterSessions(

  events: ExecutionEvent[],

  maxGapMs: number = 1000 * 60 * 15 // 15 minutes

): EventSession[] {

  if (!events.length) return [];

  const sessions: EventSession[] = [];

  let current: EventSession = {

    id: `session_${events[0].id}`,

    startTime: events[0].timestamp,

    endTime: events[0].timestamp,

    events: [events[0]],

    dominantAction: events[0].action,

    dominantFile: events[0].affectedFiles?.[0]

  };

  for (let i = 1; i < events.length; i++) {

    const event = events[i];

    const prev = events[i - 1];

    const timeGap = event.timestamp - prev.timestamp;

    const sameFile =

      event.affectedFiles?.[0] &&

      event.affectedFiles?.[0] === prev.affectedFiles?.[0];

    const sameAction = event.action === prev.action;

    const continueSession =

      timeGap <= maxGapMs || sameFile || sameAction;

    if (continueSession) {

      current.events.push(event);

      current.endTime = event.timestamp;

    } else {

      sessions.push(current);

      current = {

        id: `session_${event.id}`,

        startTime: event.timestamp,

        endTime: event.timestamp,

        events: [event],

        dominantAction: event.action,

        dominantFile: event.affectedFiles?.[0]

      };

    }

  }

  sessions.push(current);

  return sessions;

}

