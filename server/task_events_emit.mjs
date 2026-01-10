/**
 * Phase 25 — Authority & Orchestration Lock
 * This module MUST NOT write to the database directly.
 * It exists only as a compatibility wrapper that routes to the single writer.
 *
 * SINGLE AUTHORITATIVE TASK EVENT WRITER — Phase 25 contract enforced.
 * Source of truth: server/task-events.mjs
 */

export { emitTaskEvent, writeTaskEvent } from "./task-events.mjs";
