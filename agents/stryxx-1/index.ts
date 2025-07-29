import { compileInstruction } from "../compiler/index";
import sqlite3 from "sqlite3";
import { open } from "sqlite";

async function runSTRYXX(input: string) {
  const db = await open({
    filename: "memory/agent_memory.db",
    driver: sqlite3.Database
  });

  const { steps } = compileInstruction(input);

  const prioritized = steps.map((step, i) => ({
    step,
    priority: steps.length - i
  }));

  for (const { step, priority } of prioritized) {
    await db.run(
      `INSERT INTO compiled_tasks (input, step, agent, executed) VALUES (?, ?, ?, ?)`,
      input, step, 'stryxx-1', 0
    );

    await db.run(
      `INSERT INTO logs (agent, message) VALUES (?, ?)`,
      'stryxx-1',
      `Queued task: "${step}" with priority ${priority}`
    );
  }

  await db.close();

  console.log("✅ STRYXX-1: Compiled, prioritized, and logged tasks.");
}

if (process.argv[2]) {
  runSTRYXX(process.argv.slice(2).join(" ")).catch(console.error);
} else {
  console.log("⚠️ Please provide an instruction string as an argument.");
}
