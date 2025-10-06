// <0001fb1a> Reflections Router (safe inline imports to avoid timing issues)
import express from "express";

export const reflectionsRouter = express.Router();

reflectionsRouter.get("/all", async (req, res) => {
  const { reflectionsAllHandler } = await import("./reflections-all");
  return reflectionsAllHandler(req, res);
});

reflectionsRouter.get("/latest", async (req, res) => {
  const { reflectionsLatestHandler } = await import("./reflections-latest");
  return reflectionsLatestHandler(req, res);
});

console.log("<0001fb1a> reflectionsRouter safely initialized with lazy handler imports");
