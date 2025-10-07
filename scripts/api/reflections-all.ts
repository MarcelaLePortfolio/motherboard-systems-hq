// <0001fb6C> reflectionsAllHandler – guaranteed Express 5 JSON response
import fs from "fs";
import path from "path";
import { Request, Response } from "express";

export function reflectionsAllHandler(_req: Request, res: Response) {
  const dbPath = path.resolve("db/reflections.json");
  try {
    const data = fs.existsSync(dbPath)
      ? JSON.parse(fs.readFileSync(dbPath, "utf8") || "[]")
      : [];
    res.status(200).json(data);
  } catch (err) {
    console.error("Error reading reflections.json:", err);
    res.status(500).json({ error: "Failed to read reflections" });
  }
}
