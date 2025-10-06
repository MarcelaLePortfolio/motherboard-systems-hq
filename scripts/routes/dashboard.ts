import { Router } from "express";

const router = Router();

// ✅ Mock agent status
let agentStatus = {
  cade: { status: "online", lastSeen: new Date().toISOString() },
  matilda: { status: "online", lastSeen: new Date().toISOString() }
};

// ✅ In-memory arrays as DB fallback
export let mockTasks = [
  { id: "t1", command: "dev:clean", status: "completed", ts: new Date().toISOString() }
];

export let mockLogs = [
  { id: "r1", reflection: "System started clean", ts: new Date().toISOString() }
];

// --- Routes ---

// Agents
router.get("/status/agents", (_req, res) => {
  res.json(agentStatus);
});

// Tasks (mocked)
router.get("/tasks/recent", async (_req, res) => {
  res.json(mockTasks.slice(-10).reverse());
});

// Logs (mocked)
router.get("/logs/recent", async (_req, res) => {
  res.json(mockLogs.slice(-10).reverse());
});

export const dashboardRoutes = router;

// ✅ Export router for use in server.ts
export default router;
