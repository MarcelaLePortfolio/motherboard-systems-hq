
import { emitPersistentEvent } from "../events/execution-event-store";

export function recordExecutionEvent(event: any) {

  emitPersistentEvent({

    id: crypto.randomUUID(),

    timestamp: Date.now(),

    ...event

  });

}

