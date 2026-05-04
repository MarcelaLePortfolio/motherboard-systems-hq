/**
 * PHASE 641 — ROUTE REGISTRATION (GUIDANCE SSE + EXISTING)
 */

import { registerSubsystemStatusRoute } from './subsystem-status.js';
import { registerSubsystemSSERoute } from './subsystem-sse.js';
import { registerGuidanceRoute } from './guidance.js';
import { registerGuidanceSSERoute } from './guidance-sse.js';

export function registerRoutes(app) {
  // existing routes assumed preserved externally

  registerSubsystemStatusRoute(app);
  registerSubsystemSSERoute(app);
  registerGuidanceRoute(app);
  registerGuidanceSSERoute(app);
}
