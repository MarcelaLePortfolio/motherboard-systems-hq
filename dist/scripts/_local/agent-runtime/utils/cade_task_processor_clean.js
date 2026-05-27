/* eslint-disable import/no-commonjs */
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
                console.log("Shell command success:", command, "Output:", stdout);
                resolve();
            }
        });
    });
}
async function processTasks() {
    const tasks = loadTasks();
    let changed = false;
    for (const task of tasks) {
        if (task.status === "Pending" && task.type === "run_shell") {
            try {
                await runShellCommand(task.command);
                task.status = "Completed";
                changed = true;
            }
            catch {
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
    console.log("⚡ Cade Task Processor: Started, polling every 3 seconds...");
    setInterval(() => {
        processTasks().catch(console.error);
    }, 3000);
}
