/**
 * PHASE 633 — ACTIVE SERVER ROUTE INJECTION
 * Ensures subsystem routes are available for active runtime mounting.
 * Safe: read-only route registration only.
 */

import { registerSubsystemStatusRoute } from '../routes/subsystem-status.js';

export function applyRouteRegistration(app) {
  registerSubsystemStatusRoute(app);
}
