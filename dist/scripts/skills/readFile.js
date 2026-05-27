import fs from "fs";
import path from "path";
export default async function (payload) {
    const filePath = path.join(process.cwd(), "memory", payload.filename || "");
    if (!fs.existsSync(filePath))
        throw new Error("File not found");
    return fs.readFileSync(filePath, "utf8");
}
