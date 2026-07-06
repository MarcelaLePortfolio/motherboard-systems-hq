
import { sqlite } from "./client.js";

// RAW SQLITE ONLY LEGACY WRAPPER (NO ORM LAYER)

export const db = sqlite;

// task_events compatibility surface (used by legacy routes)

export const task_events = {

  list: () => sqlite.prepare("SELECT * FROM task_events").all(),

  insert: (row: any) =>

    sqlite.prepare(`

      INSERT INTO task_events

      VALUES (?, ?, ?, ?, ?, ?, ?)

    `).run(row)

};

