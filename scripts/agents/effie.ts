import fs from "fs";
import path from "path";

export async function effieCommandRouter(command: string, params: any = {}) {
  try {
    switch (command) {
      case "list files": {
        const dir = params.path || ".";
        const files = fs.readdirSync(dir);
        return { status: "success", files };
      }
      case "read file": {
        const filePath = params.path;
        if (!filePath || !fs.existsSync(filePath)) {
          return { status: "error", message: "File not found" };
        }
        const content = fs.readFileSync(filePath, "utf8");
        return { status: "success", content };
      }
      default:
        return { status: "error", message: `Unknown Effie command: ${command}` };
    }
  } catch (err) {
    return { status: "error", message: (err as Error).message };
  }
}
