
import { sqlite } from "./client.js";

export const task_events = sqlite.prepare("SELECT * FROM task_events");

