/**
 * PHASE 636 — ROUTE REGISTRATION (SSE + STATUS)
 */

import { registerSubsystemStatusRoute } from './subsystem-status.js';
import { registerSubsystemSSERoute } from './subsystem-sse.js';

export function registerRoutes(app) {
  // existing routes assumed preserved externally

  registerSubsystemStatusRoute(app);
  registerSubsystemSSERoute(app);
}
