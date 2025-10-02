import { Router } from "express";

const router = Router();

// <0001f7e1> MVP mock data until DB is wired
let agentStatus = {
  cade: { status: "online", lastSeen: new Date().toISOString() },
  matilda: { status: "online", lastSeen: new Date().toISOString() }
};

let taskQueue = [
  { id: "t1", command: "dev:clean", status: "completed", ts: new Date().toISOString() }
];

let reflections = [
  { id: "r1", reflection: "System started clean", ts: new Date().toISOString() }
];

// --- Routes ---
router.get("/status/agents", (_req, res) => {
  res.json(agentStatus);
});

router.get("/tasks/recent", (_req, res) => {
  res.json(taskQueue);
});

router.get("/logs/recent", (_req, res) => {
  res.json(reflections);
});

export default router;
