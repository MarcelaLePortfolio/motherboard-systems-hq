// <0001fb78> reflectionsLatestHandler – Express 5 guaranteed JSON output
import fs from "fs";
import path from "path";
import { Request, Response } from "express";

export function reflectionsLatestHandler(_req: Request, res: Response) {
  try {
    const dbPath = path.resolve("db/reflections.json");
    const data = fs.existsSync(dbPath)
      ? JSON.parse(fs.readFileSync(dbPath, "utf8") || "[]")
      : [];
    const latest = Array.isArray(data) ? data[data.length - 1] : null;
    res.status(200).json(latest);
  } catch (err) {
    console.error("<0001fb78> Error reading reflections.json:", err);
    res.status(500).json({ error: "Failed to read reflections.json" });
  }
}
