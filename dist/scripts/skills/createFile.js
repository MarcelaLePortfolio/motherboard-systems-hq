import fs from "fs";
import path from "path";
export default async function (payload) {
    const filePath = path.join(process.cwd(), "memory", payload.filename || `file_${Date.now()}.txt`);
    fs.writeFileSync(filePath, "�� Dynamic learning test", "utf8");
    return filePath;
}
