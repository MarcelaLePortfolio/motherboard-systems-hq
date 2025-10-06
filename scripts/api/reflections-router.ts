// <0001fb14> Unified reflections router
import express from "express";
import { reflectionsAllHandler } from "./reflections-all";
import { reflectionsLatestHandler } from "./reflections-latest";

export const reflectionsRouter = express.Router();

reflectionsRouter.get("/all", reflectionsAllHandler);
reflectionsRouter.get("/latest", reflectionsLatestHandler);

console.log("🪞 reflectionsRouter initialized successfully");
