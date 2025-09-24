import fs from "fs";
import path from "path";
import { callOllama } from "../utils/ollama";

export const cade = {
  name: "Cade",
  start: async () => {
    console.log("🤖 Cade ready and waiting for tasks...");

    const taskFile = path.join("memory", "tasks", "test_reasoning.json");
    if (fs.existsSync(taskFile)) {
      const raw = fs.readFileSync(taskFile, "utf-8");
      const task = JSON.parse(raw);

      if (task.type === "reasoning" && task.prompt) {
        console.log("🧠 Running reasoning task with Ollama...");
        const response = await callOllama(task.prompt);
        console.log("🧠 Response:", response);
      } else {
        console.log("⚠️ Task is missing required fields (type='reasoning' and a prompt)");
      }
    } else {
      console.log("📭 No reasoning task file found.");
    }
  },
};
