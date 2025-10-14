import express from "express";
import fs from "fs";
import path from "path";

const router = express.Router();
router.get("/recent", (req, res) => {
  const file = path.join(process.cwd(), "memory", "tasks.json");
  let tasks = [];
  if (fs.existsSync(file)) {
    try { tasks = JSON.parse(fs.readFileSync(file, "utf8")); } catch { tasks = []; }
  }
  res.json(tasks);
});
export default router;
