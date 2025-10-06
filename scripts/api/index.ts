// <0001face> Final reflections API router — synchronous import, guaranteed mount
import express from "express";
import { reflectionsAllHandler } from "./reflections-all";
import { reflectionsLatestHandler } from "./reflections-latest";

export const reflectionsRouter = express.Router();

reflectionsRouter.get("/all", (req, res) => {
  console.log("📡 Hit /api/reflections/all");
  return reflectionsAllHandler(req, res);
});

reflectionsRouter.get("/latest", (req, res) => {
  console.log("📡 Hit /api/reflections/latest");
  return reflectionsLatestHandler(req, res);
});

console.log("✅ ReflectionsRouter initialized with /all and /latest endpoints");
