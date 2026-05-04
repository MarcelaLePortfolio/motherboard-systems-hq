/**
 * PHASE 639 — ACTIVE SERVER ROUTE INJECTION
 * Ensures subsystem + guidance routes are available for active runtime mounting.
 * Safe: read-only route registration only.
 */

import { registerSubsystemStatusRoute } from '../routes/subsystem-status.js';
import { registerSubsystemSSERoute } from '../routes/subsystem-sse.js';
import { registerGuidanceRoute } from '../routes/guidance.js';

export function applyRouteRegistration(app) {
  registerSubsystemStatusRoute(app);
  registerSubsystemSSERoute(app);
  registerGuidanceRoute(app);
}
