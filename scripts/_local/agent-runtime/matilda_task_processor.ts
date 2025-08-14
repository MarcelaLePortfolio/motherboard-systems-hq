import { matilda } from "../../agents/matilda/matilda.mjs";
import { readChainTaskFile } from "../utils/chain.mjs";
import { log } from "../utils/log.mjs";

async function run() {
  const task = await readChainTaskFile();
  const result = await matilda.handler(task);
  await log(result);
}

run().catch(console.error);
