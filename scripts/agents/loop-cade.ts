import { db } from "@/db";
import { agentTasks } from "@/db/schema";
import { eq } from "drizzle-orm";
import { handleTask } from "./cade";

async function mainLoop() {
  while (true) {
    const task = await db.query.agentTasks.findFirst({
      where: (fields) => eq(fields.status, "Pending"),
      orderBy: (fields) => fields.ts,
    });

    if (!task) {
      await new Promise((resolve) => setTimeout(resolve, 5000));
      continue;
    }

    console.log(`🤖 Cade executing task ${task.id}: ${task.type}`);

    try {
      const result = await handleTask(task);
      console.log(`✅ Cade completed task ${task.id}: ${task.type}`);
      await db
        .update(agentTasks)
        .set({ status: "Done", ts: Date.now() })
        .where(eq(agentTasks.id, task.id));
    } catch (err) {
      console.error("Fatal error while processing task", err);
      await db.insert(agentTasks).values({
        agent: "Matilda",
        type: "log",
        status: "Pending",
        content: `Cade failed task ${task.id}: ${task.type}`,
        ts: Date.now(),
      });
    }
  }
}

mainLoop();
