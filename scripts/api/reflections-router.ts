// <0001fb47> canonical reflectionsRouter export (Express v5-compatible)
import express from "express";
import { reflectionsAllHandler } from "./reflections-all";
import { reflectionsLatestHandler } from "./reflections-latest";

const router = express.Router();

// ✅ Explicitly register routes
router.get("/all", reflectionsAllHandler);
router.get("/latest", reflectionsLatestHandler);

console.log("<0001fb47> reflectionsRouter initialized and routes registered");

export default router;
