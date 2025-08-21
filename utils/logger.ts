import fs from "fs";
import path from "path";

const OPS_STREAM_PATH = path.resolve("logs/ops-stream.log");

export function logToOpsStream(message: string) {
  const timestamp = new Date().toISOString();
  const logMessage = `[${timestamp}] ${message}\n`;
  fs.appendFileSync(OPS_STREAM_PATH, logMessage, "utf8");
}
