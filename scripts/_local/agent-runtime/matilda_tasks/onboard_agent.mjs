import fs from "fs";
import path from "path";

const statePath = path.join(__dirname, "../memory/agent_chain_state.json");

function writeTask(type, summary) {
  const task = { type, summary };
  fs.writeFileSync(statePath, JSON.stringify(task, null, 2));
  console.log(`<0001fa9e> Matilda delegated: ${summary}`);
}

writeTask("generate_file", "📁 Create a welcome kit markdown file for new agents");
