/**
 * PHASE 633 — ROUTE REGISTRATION (SUBSYSTEM STATUS)
 * Safe: read-only endpoint wiring
 */

import { registerSubsystemStatusRoute } from './subsystem-status.js';

export function registerRoutes(app) {
  // existing routes should already be here

  // PHASE 633 — add subsystem status route
  registerSubsystemStatusRoute(app);
}
