import { readFileSync, writeFileSync } from "fs";
import { exec } from "child_process";
const filePath = "./memory/agent_chain_state.json";
function loadTasks() {
    try {
        const data = readFileSync(filePath, "utf-8");
        return JSON.parse(data);
    }
    catch {
        return [];
    }
}
function saveTasks(tasks) {
    writeFileSync(filePath, JSON.stringify(tasks, null, 2));
}
function runShellCommand(command) {
    return new Promise((resolve, reject) => {
        exec(command, (error, stdout, stderr) => {
            if (error) {
                console.error("Shell command error:", command, error);
                reject(error);
            }
            else {
                console.log("Shell command success:", command, "\nOutput:", stdout);
                resolve();
            }
        });
    });
}
async function processTasks() {
    const tasks = loadTasks();
    let changed = false;
    for (const task of tasks) {
        if (task.status === "Pending") {
            try {
                switch (task.type) {
                    case "run_shell":
                        await runShellCommand(task.command);
                        break;
                    case "write_db":
                        const tablePath = "./memory/" + task.table + ".json";
                        let rows = [];
                        try {
                            rows = JSON.parse(readFileSync(tablePath, "utf-8"));
                        }
                        catch { }
                        rows.push(task.row);
                        writeFileSync(tablePath, JSON.stringify(rows, null, 2));
                        break;
                    case "local_task":
                        console.log("Running local task: " + task.task + "");
                        break;
                    default:
                        console.warn("Unknown task type: " + task.type + "");
                        break;
                }
                task.status = "Completed";
                changed = true;
            }
            catch (e) {
                console.error("Task failed: " + e + "");
                task.status = "Failed";
                changed = true;
            }
        }
    }
    if (changed) {
        saveTasks(tasks);
    }
}
export function startCadeTaskProcessor() {
    console.log(" Cade Task Processor: Started, polling every 3 seconds...");
    setInterval(() => {
        processTasks().catch(console.error);
    }, 3000);
}
