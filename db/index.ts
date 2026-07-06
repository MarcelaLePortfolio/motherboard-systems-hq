
import { sqlite } from "./client.js";

export const db = {

  taskEvents: {

    list: () => sqlite.prepare("SELECT * FROM task_events").all(),

    insert: (row: any) => sqlite.prepare("INSERT INTO task_events VALUES (?)").run(row)

  },

  reflections: {

    list: () => sqlite.prepare("SELECT * FROM reflections").all()

  },

  health: {

    ping: () => sqlite.prepare("SELECT 1").get()

  }

};

