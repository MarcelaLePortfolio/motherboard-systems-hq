export default async function inferAgentHandler(options) {
    const taskDescription = options?.task || "";
    let assignedAgent = "Matilda";
    let reasoning = "Task routed to Matilda by default.";

    if (/file|disk|memory|backup|zip/i.test(taskDescription)) {
        assignedAgent = "Cade";
        reasoning = "Task involves file or memory operations, best handled by Cade.";
    } else if (/desktop|local|open|close|run/i.test(taskDescription)) {
        assignedAgent = "Effie";
        reasoning = "Task involves desktop operations, best handled by Effie.";
    }

    return { assignedAgent, reasoning };
}
