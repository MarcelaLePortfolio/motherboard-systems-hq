// <0001fb7C> reflectionsRouter – final mount fix (adds /reflections prefix)
import express from "express";
import { reflectionsAllHandler } from "./reflections-all";
import { reflectionsLatestHandler } from "./reflections-latest";

const router = express.Router();

// ✅ Define full route paths to avoid prefix confusion
router.get("/reflections", (_req, res) => res.json({ ok: true, routes: ["/all", "/latest"] }));
router.get("/reflections/all", reflectionsAllHandler);
router.get("/reflections/latest", reflectionsLatestHandler);

console.log("<0001fb7C> reflectionsRouter mounted with explicit /reflections prefix");
export default router;
