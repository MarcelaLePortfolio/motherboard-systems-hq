// <0001fb7D> reflectionsRouter – final flatten (true /api/reflections/* JSON)
import express from "express";
import { reflectionsAllHandler } from "./reflections-all";
import { reflectionsLatestHandler } from "./reflections-latest";

const router = express.Router();

// ✅ Correct relative paths – final verified structure
router.get("/", (_req, res) => res.json({ ok: true, routes: ["/all", "/latest"] }));
router.get("/all", reflectionsAllHandler);
router.get("/latest", reflectionsLatestHandler);

console.log("<0001fb7D> reflectionsRouter flattened for /api/reflections/*");
export default router;
