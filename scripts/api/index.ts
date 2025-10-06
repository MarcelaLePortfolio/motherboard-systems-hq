// <0001fabc> Express router for reflections API (CommonJS-safe loader)
import express from "express";

export const reflectionsRouter = express.Router();

(async () => {
  const { reflectionsAllHandler } = await import("./reflections-all.js").catch(() => require("./reflections-all"));
  const { reflectionsLatestHandler } = await import("./reflections-latest.js").catch(() => require("./reflections-latest"));

  reflectionsRouter.get("/all", (req, res) => reflectionsAllHandler(req, res));
  reflectionsRouter.get("/latest", (req, res) => reflectionsLatestHandler(req, res));
})();
