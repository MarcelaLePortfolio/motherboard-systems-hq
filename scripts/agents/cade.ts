import fs from "fs";
import path from "path";
import crypto from "crypto";

export const cadeCommandRouter = async (command: string, payload: any = {}) => {
  console.log("🧠 Cade ready to receive commands.");
  let result;

  switch (command) {
    case "write to file": {
      try {
        const resolvedPath = path.resolve(payload.path);
        fs.writeFileSync(resolvedPath, payload.content, "utf8");

        const fileBuffer = fs.readFileSync(resolvedPath);
        const hash = crypto.createHash("sha256").update(fileBuffer).digest("hex");

        result = {
          status: "success",
          message: `File written to ${payload.path}`,
          file_hash: hash,
        };
      } catch (err: any) {
        result = {
          status: "error",
          message: `❌ Error writing file: ${err.message}`,
        };
      }
      break;
    }

    default: {
      result = {
        status: "error",
        message: "Unknown command",
      };
      break;
    }
  }

  return result;
};
