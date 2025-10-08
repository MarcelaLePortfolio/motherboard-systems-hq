import type { Express } from "express";
import express from "express";

let appInstance: Express | null = null;

export function getApp(): Express {
  if (!appInstance) {
    appInstance = express();
  }
  return appInstance;
}
