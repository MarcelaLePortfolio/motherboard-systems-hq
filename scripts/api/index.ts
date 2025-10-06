// <0001fac9> Correct router export for reflections API
import express from "express";
import { reflectionsAllHandler } from "./reflections-all";
import { reflectionsLatestHandler } from "./reflections-latest";

export const reflectionsRouter = express.Router();
reflectionsRouter.get("/all", reflectionsAllHandler);
reflectionsRouter.get("/latest", reflectionsLatestHandler);
