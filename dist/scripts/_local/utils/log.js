import fs from "fs/promises";
export async function log(...messages) {
    const output = messages.map(m => (typeof m === "string" ? m : JSON.stringify(m, null, 2))).join(" ");
    await fs.appendFile("memory/log.txt", output + "\n");
    console.log(output);
}
