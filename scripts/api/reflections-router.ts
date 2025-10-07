// <0001fb57> Final verified reflections router – Express 5 compatible
import express from "express";
import { reflectionsAllHandler } from "./reflections-all";
import { reflectionsLatestHandler } from "./reflections-latest";

const router = express.Router();

// ✅ Register endpoints explicitly
router.get("/all", (req, res) => {
  try {
    const result = reflectionsAllHandler(req, res);
    if (!res.headersSent) res.json(result);
  } catch (err) {
    console.error("Error in /all:", err);
    if (!res.headersSent) res.status(500).json({ error: "Internal Server Error" });
  }
});

router.get("/latest", (req, res) => {
  try {
    const result = reflectionsLatestHandler(req, res);
    if (!res.headersSent) res.json(result);
  } catch (err) {
    console.error("Error in /latest:", err);
    if (!res.headersSent) res.status(500).json({ error: "Internal Server Error" });
  }
});

export default router;
