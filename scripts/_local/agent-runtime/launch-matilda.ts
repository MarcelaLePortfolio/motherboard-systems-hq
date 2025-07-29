import readline from "readline";

console.log("🧠 Matilda ready. Type a command…");

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  prompt: "Matilda> "
});

rl.prompt();

rl.on("line", (input) => {
  const cleanInput = input.trim();
  if (!cleanInput) {
    rl.prompt();
    return;
  }

  let response = "";

  // Basic command handling
  const lower = cleanInput.toLowerCase();
  if (lower.includes("status")) {
    response = "All agents are online and operational. ✅";
  } else if (lower.includes("effie")) {
    response = "Forwarding request to Effie… (stub)";
  } else if (lower.includes("cade")) {
    response = "Forwarding request to Cade… (stub)";
  } else if (lower.includes("hello") || lower.includes("hi")) {
    response = "Hello! Matilda here, ready to assist you. 💁‍♀️";
  } else if (lower.includes("backup")) {
    response = "I would normally trigger Cade for a backup, but this is a stub for now.";
  } else {
    response = `Matilda: I heard you say “${cleanInput}”, but I need more details.`;
  }

  console.log(response);
  rl.prompt();
});

rl.on("close", () => {
  console.log("👋 Matilda shutting down. Have a great day!");
  process.exit(0);
});
