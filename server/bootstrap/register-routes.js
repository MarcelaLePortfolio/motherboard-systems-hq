/**
 * PHASE 641 — ACTIVE SERVER ROUTE INJECTION
 * Ensures subsystem + guidance API/SSE routes are available for active runtime mounting.
 * Safe: read-only route registration only.
 */

import { registerSubsystemStatusRoute } from '../routes/subsystem-status.js';
import { registerSubsystemSSERoute } from '../routes/subsystem-sse.js';
import { registerGuidanceRoute } from '../routes/guidance.js';
import { registerGuidanceSSERoute } from '../routes/guidance-sse.js';

export function applyRouteRegistration(app) {
  registerSubsystemStatusRoute(app);
  registerSubsystemSSERoute(app);
  registerGuidanceRoute(app);
  registerGuidanceSSERoute(app);
}
