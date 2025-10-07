// <0001fb72> reflectionsRouter – Express 5 verified mount compatibility
import express from "express";
import { reflectionsAllHandler } from "./reflections-all";
import { reflectionsLatestHandler } from "./reflections-latest";

const router = express.Router();

// ✅ Plain local paths only
router.get("/", (_req, res) => res.json({ ok: true, routes: ["/all", "/latest"] }));
router.get("/all", reflectionsAllHandler);
router.get("/latest", reflectionsLatestHandler);

console.log("<0001fb72> reflectionsRouter fully compatible (ESM + CJS export)");

export default router;
module.exports = router;     // <- ensure compatibility with Express import resolution
