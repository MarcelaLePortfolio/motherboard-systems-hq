// <0001fb89> reflectionsAllHandler – explicit JSON enforcement
import fs from "fs";
import path from "path";
import { Request, Response } from "express";

export function reflectionsAllHandler(_req: Request, res: Response) {
  try {
    const dbPath = path.resolve("db/reflections.json");
    const content = fs.existsSync(dbPath) ? fs.readFileSync(dbPath, "utf8") : "[]";
    const parsed = JSON.parse(content);
    res.setHeader("Content-Type", "application/json");
    res.status(200).json(parsed);
  } catch (err) {
    console.error("<0001fb89> Error reading reflections.json:", err);
    res.status(500).json({ error: "Failed to read reflections.json" });
  }
}
