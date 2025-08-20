export async function handleEcho(task) {
  console.log("📣 [CADE] Echoing:", task.content || task.instructions);
  return { status: "completed", result: task.content || task.instructions || "Echoed" };
}
