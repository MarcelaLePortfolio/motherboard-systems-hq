// <0001fbB0> reflectionsRouter – modular version of working inline routes
import express from "express";
import fs from "fs";
import path from "path";

const router = express.Router();

// ✅ /api/reflections/ping
router.get("/ping", (_req, res) => {
  res.json({ ok: true, msg: "reflections alive" });
});

// ✅ /api/reflections/all
router.get("/all", (_req, res) => {
  const dbPath = path.resolve("db/reflections.json");
  const data = fs.existsSync(dbPath)
    ? JSON.parse(fs.readFileSync(dbPath, "utf8"))
    : [];
  res.json(data);
});

// ✅ /api/reflections/latest
router.get("/latest", (_req, res) => {
  const dbPath = path.resolve("db/reflections.json");
  const data = fs.existsSync(dbPath)
    ? JSON.parse(fs.readFileSync(dbPath, "utf8"))
    : [];
  res.json(data[data.length - 1] || {});
});

export default router;
