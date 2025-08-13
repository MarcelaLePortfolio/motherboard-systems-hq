import { matilda } from "../../agents/matilda.ts";
import { readChainTaskFile } from "../utils/chain.ts";
import { log } from "../utils/log.ts";

async function run() {
  const task = await readChainTaskFile();
  const result = await matilda.handler(task);
  await log(result);
}

run().catch(console.error);
