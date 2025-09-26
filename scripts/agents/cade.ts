import fs from "fs";
import path from "path";
import crypto from "crypto";

const cadeCommandRouter = async (command: string, payload: any = {}) => {
  let result = "";

  switch (command) {
    case "write to file": {
      const { path: filePath, content } = payload;
      const resolvedPath = path.resolve(filePath);
      try {
        fs.writeFileSync(resolvedPath, content, "utf8");
        const fileBuffer = fs.readFileSync(resolvedPath);
        const hash = crypto.createHash("sha256").update(fileBuffer).digest("hex");
        result = `📝 File written to "${filePath}" (sha256: ${hash})`;
      } catch (err: any) {
        result = `❌ Error: ${err.message || String(err)}`;
      }
      break;
    }

    default: {
      result = "🤷 Unknown task type";
    }
  }

  return { status: "success", result };
};

export { cadeCommandRouter };
