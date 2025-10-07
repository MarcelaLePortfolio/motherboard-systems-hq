// <0001fb70> Dashboard router – strict /api isolation (Express 5 verified)
import express from "express";
const router = express.Router();

// 🚧 Abort any /api/* requests immediately
router.use((req, res, next) => {
  if (req.path.startsWith("/api")) return res.status(404).json({ error: "API route not found" });
  next();
});

// ✅ Homepage
router.get("/", (_req, res) => {
  res.send("<h1>Welcome to the Motherboard Systems Dashboard</h1>");
});

// ✅ Regex-safe fallback for all non-API routes
router.get(/^\/(?!api\/).*/, (_req, res) => {
  res.status(404).send("<h1>404 – Page not found</h1>");
});

export default router;
