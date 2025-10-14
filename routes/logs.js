import express from "express";
import fs from "fs";
import path from "path";

const router = express.Router();
router.get("/recent", (req, res) => {
  const file = path.join(process.cwd(), "memory", "logs.json");
  let logs = [];
  if (fs.existsSync(file)) {
    try { logs = JSON.parse(fs.readFileSync(file, "utf8")); } catch { logs = []; }
  }
  res.json(logs);
});
export default router;
