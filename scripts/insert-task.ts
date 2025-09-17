import fs from "fs";
import path from "path";
import { insertTask } from "../db/task-db";
import { v4 as uuidv4 } from "uuid";

// Parse arguments
const args = process.argv.slice(2);
const getArg = (name: string) => {
  const index = args.indexOf(`--${name}`);
  return index !== -1 && args[index + 1] ? args[index + 1] : null;
};

const type = getArg("type");
const content = getArg("content");
const agent = getArg("agent");
const filePath = getArg("path");

if (!type || !content || !agent) {
  console.error("❌ Missing required arguments: --type, --content, --agent [--path]");
  process.exit(1);
}

const task = {
  uuid: uuidv4(),
  type,
  content,
  agent,
  status: "queued",
  created_at: Date.now(),
  triggered_by: null,
  ...(filePath ? { path: filePath } : {})
};

insertTask(task);
console.log("✅ Task inserted:", task);
