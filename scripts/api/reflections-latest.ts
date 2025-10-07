// <0001fb89> reflectionsLatestHandler – explicit JSON enforcement
import fs from "fs";
import path from "path";
import { Request, Response } from "express";

export function reflectionsLatestHandler(_req: Request, res: Response) {
  try {
    const dbPath = path.resolve("db/reflections.json");
    const content = fs.existsSync(dbPath) ? fs.readFileSync(dbPath, "utf8") : "[]";
    const parsed = JSON.parse(content);
    const latest = Array.isArray(parsed) ? parsed[parsed.length - 1] : null;
    res.setHeader("Content-Type", "application/json");
    res.status(200).json(latest || {});
  } catch (err) {
    console.error("<0001fb89> Error reading reflections.json:", err);
    res.status(500).json({ error: "Failed to read reflections.json" });
  }
}
