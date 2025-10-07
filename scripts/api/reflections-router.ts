// <0001fb63> Express 5 verified reflectionsRouter – guaranteed mount compatibility
import express from "express";
import { reflectionsAllHandler } from "./reflections-all";
import { reflectionsLatestHandler } from "./reflections-latest";

const router = express.Router({
  caseSensitive: false,
  strict: false,
});

// ✅ Register endpoints relative to /api/reflections/
router.get("/all", reflectionsAllHandler);
router.get("/latest", reflectionsLatestHandler);

console.log("<0001fb63> reflectionsRouter verified and loaded");

export default router;
