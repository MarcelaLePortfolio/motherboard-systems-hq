// <0001fb1f> Canonical reflections router (final stable version)
import express from "express";
import { reflectionsAllHandler } from "./reflections-all";
import { reflectionsLatestHandler } from "./reflections-latest";

const reflectionsRouter = express.Router();

reflectionsRouter.get("/all", reflectionsAllHandler);
reflectionsRouter.get("/latest", reflectionsLatestHandler);

console.log("<0001fb1f> reflectionsRouter registered with /all and /latest");

export default reflectionsRouter;
