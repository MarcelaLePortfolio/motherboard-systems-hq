// <0001fb59> reflectionsLatestHandler – returns most recent reflection
import fs from "fs";
import path from "path";
import { Request, Response } from "express";

export function reflectionsLatestHandler(req: Request, res: Response) {
  const dbPath = path.resolve("db/reflections.json");
  if (!fs.existsSync(dbPath)) return null;

  try {
    const data = JSON.parse(fs.readFileSync(dbPath, "utf8") || "[]");
    return Array.isArray(data) ? data[data.length - 1] : null;
  } catch (err) {
    console.error("Error reading reflections.json:", err);
    return null;
  }
}
