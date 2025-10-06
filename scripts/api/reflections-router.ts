// <0001fb20> reflections router (final route normalization)
import express from "express";
import { reflectionsAllHandler } from "./reflections-all";
import { reflectionsLatestHandler } from "./reflections-latest";

const reflectionsRouter = express.Router({ strict: false, caseSensitive: false });

reflectionsRouter.get(["/", "/all"], reflectionsAllHandler);
reflectionsRouter.get("/latest", reflectionsLatestHandler);

console.log("<0001fb20> reflectionsRouter active for /, /all, and /latest");

export default reflectionsRouter;
