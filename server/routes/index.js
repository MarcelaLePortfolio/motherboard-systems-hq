/**
 * PHASE 639 — ROUTE REGISTRATION (GUIDANCE + SUBSYSTEM)
 */

import { registerSubsystemStatusRoute } from './subsystem-status.js';
import { registerSubsystemSSERoute } from './subsystem-sse.js';
import { registerGuidanceRoute } from './guidance.js';

export function registerRoutes(app) {
  // existing routes assumed preserved externally

  registerSubsystemStatusRoute(app);
  registerSubsystemSSERoute(app);
  registerGuidanceRoute(app);
}
