// <0001fb69> reflectionsRouter – normalized for /api/reflections mount
import express from "express";
import { reflectionsAllHandler } from "./reflections-all";
import { reflectionsLatestHandler } from "./reflections-latest";

const router = express.Router({
  caseSensitive: false,
  strict: false,
});

// ✅ Register plain local paths (no /api prefix)
router.get("/", (_req, res) => {
  res.json({ status: "ok", routes: ["/all", "/latest"] });
});
router.get("/all", reflectionsAllHandler);
router.get("/latest", reflectionsLatestHandler);

console.log("<0001fb69> reflectionsRouter normalized for /api/reflections");

export default router;
