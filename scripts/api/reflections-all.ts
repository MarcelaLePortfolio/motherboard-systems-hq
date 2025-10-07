// <0001fb58> reflectionsAllHandler – returns full reflection list
import fs from "fs";
import path from "path";
import { Request, Response } from "express";

export function reflectionsAllHandler(req: Request, res: Response) {
  const dbPath = path.resolve("db/reflections.json");
  if (!fs.existsSync(dbPath)) return [];

  try {
    const data = JSON.parse(fs.readFileSync(dbPath, "utf8") || "[]");
    return data;
  } catch (err) {
    console.error("Error reading reflections.json:", err);
    return [];
  }
}
