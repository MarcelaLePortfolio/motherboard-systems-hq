import { matilda } from "../../agents/matilda/matilda";
import { readChainTaskFile } from "../utils/chain";
import { log } from "../utils/log";
async function run() {
    const task = await readChainTaskFile();
    const result = await matilda.handler(task);
    await log(result);
}
run().catch(console.error);
