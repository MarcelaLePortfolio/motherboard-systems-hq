import fs from "fs";
import path from "path";
import crypto from "crypto";

export const cadeCommandRouter = async (command: string, payload: any = {}) => {
  console.log("🧠 Cade ready to receive commands.");
  let result;

  switch (command) {
    case "write to file": {
        const { path: filePath, content } = payload;
      try {
        const resolvedPath = path.resolve(payload.path);
        fs.writeFileSync(resolvedPath, payload.content, "utf8");

        const fileBuffer = fs.readFileSync(resolvedPath);
        const hash = crypto.createHash("sha256").update(fileBuffer).digest("hex");

} catch (err: any) {
  result = `❌ Error: ${err.message || String(err)}`;
}
result = `📝 File written to "${filePath}"`;
return { status: "success", result };
      break;
    }

    default: {
    }
  }

  return result;
};
