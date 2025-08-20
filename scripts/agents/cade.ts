export async function handleTask(task: any) {
  console.log("🛠️ [CADE] Handling task:", task);
  return {
    status: "completed",
    result: `Echoed: ${task.input || "No input"}`
  };
}
