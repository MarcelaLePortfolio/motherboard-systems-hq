
import fs from "fs";

const FILE = "events.log.json";

export type ExecutionEvent = {

  id: string;

  action: string;

  timestamp: number;

  input?: any;

  output?: any;

  affectedFiles?: string[];

  intent?: {

    raw: any;

    source: string;

  };

};

function readStore(): ExecutionEvent[] {

  if (!fs.existsSync(FILE)) return [];

  return JSON.parse(fs.readFileSync(FILE, "utf-8"));

}

function writeStore(events: ExecutionEvent[]) {

  fs.writeFileSync(FILE, JSON.stringify(events, null, 2));

}

export function emitEvent(event: ExecutionEvent) {

  const events = readStore();

  events.push(event);

  writeStore(events);

}

export function getEvents(): ExecutionEvent[] {

  return readStore();

}

export function clearEvents() {

  writeStore([]);

}

