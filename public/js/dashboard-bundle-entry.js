import "./dashboard-status.js";
import { initTaskGraphFromTasks } from "./dashboard-graph-loader.js";
import "./dashboard-graph.js";
import "./dashboard-broadcast.js";
import "../scripts/dashboard-reflections.js";
import "../scripts/dashboard-ops.js";
import "../scripts/dashboard-chat.js";
import "./matilda-chat-console.js";
import "./task-delegation.js";

try {
initTaskGraphFromTasks();
} catch (err) {
console.error("Failed to initialize task graph loader from bundle entry:", err);
}
