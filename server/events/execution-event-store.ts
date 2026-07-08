
import fs from "fs";

import path from "path";

import { ExecutionEvent } from "./execution-event-bus";

const FILE = path.join(process.cwd(), "events.log.json");

function readStore(): ExecutionEvent[] {

  if (!fs.existsSync(FILE)) return [];

  return JSON.parse(fs.readFileSync(FILE, "utf-8"));

}

function writeStore(events: ExecutionEvent[]) {

  fs.writeFileSync(FILE, JSON.stringify(events, null, 2));

}

export function emitPersistentEvent(event: ExecutionEvent) {

  const events = readStore();

  events.push(event);

  writeStore(events);

}

export function getPersistentEvents(): ExecutionEvent[] {

  return readStore();

}

export function clearPersistentEvents() {

  writeStore([]);

}

