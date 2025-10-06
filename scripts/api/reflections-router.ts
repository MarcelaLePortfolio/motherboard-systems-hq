// <0001fb18> Unified reflections router (final fix)
import express from "express";
import { reflectionsAllHandler } from "./reflections-all";
import { reflectionsLatestHandler } from "./reflections-latest";

export const reflectionsRouter = express.Router();

reflectionsRouter.get("/all", reflectionsAllHandler);
reflectionsRouter.get("/latest", reflectionsLatestHandler);

console.log("<0001fb18> reflectionsRouter initialized successfully with endpoints /all and /latest");
