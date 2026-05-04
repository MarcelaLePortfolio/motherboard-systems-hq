/**
 * PHASE 636 — ACTIVE SERVER ROUTE INJECTION
 * Ensures subsystem status + SSE routes are available for active runtime mounting.
 * Safe: read-only route registration only.
 */

import { registerSubsystemStatusRoute } from '../routes/subsystem-status.js';
import { registerSubsystemSSERoute } from '../routes/subsystem-sse.js';

export function applyRouteRegistration(app) {
  registerSubsystemStatusRoute(app);
  registerSubsystemSSERoute(app);
}
