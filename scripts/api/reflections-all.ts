// <0001fb77> reflectionsAllHandler – Express 5 guaranteed JSON output
import fs from "fs";
import path from "path";
import { Request, Response } from "express";

export function reflectionsAllHandler(_req: Request, res: Response) {
  try {
    const dbPath = path.resolve("db/reflections.json");
    const data = fs.existsSync(dbPath)
      ? JSON.parse(fs.readFileSync(dbPath, "utf8") || "[]")
      : [];
    res.status(200).json(data);
  } catch (err) {
    console.error("<0001fb77> Error reading reflections.json:", err);
    res.status(500).json({ error: "Failed to read reflections.json" });
  }
}
