/* eslint-disable import/no-commonjs */
import { readFileSync, writeFileSync } from "fs";
import { exec } from "child_process";
const filePath = "./memory/agent_chain_state.json";
function loadTasks() {
    try {
        const data = JSON.parse(readFileSync(filePath, "utf-8"));
        return Array.isArray(data) ? data : [];
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
                console.error("❌ Shell command error (Effie):", command, error);
                reject(error);
            }
            else {
                console.log(`✅ Shell command success (Effie): ${command}`);
                console.log(`📤 Output:\n${stdout}`);
                resolve();
            }
        });
    });
}
async function processTasks() {
    const tasks = loadTasks();
    let changed = false;
    for (const task of tasks) {
        if (task.status === "Pending" && task.agent === "Effie" && task.type === "run_shell") {
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
    if (changed)
        saveTasks(tasks);
}
export function startEffieTaskProcessor() {
    console.log("⚡ Effie Task Processor: Started, polling every 3 seconds...");
    setInterval(() => {
        processTasks().catch(console.error);
    }, 3000);
}
