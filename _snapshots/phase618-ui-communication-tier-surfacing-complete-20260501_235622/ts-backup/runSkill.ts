import fs from "fs";
import path from "path";

/**
 * 🧩 runSkill — handles basic backend task execution dynamically.
 */
export async function runSkill(task: { type: string; params?: any }) {
  try {
    switch (task.type) {
      case "createFile": {
        const filePath = path.join(process.cwd(), task.params?.path || "output.txt");
        fs.writeFileSync(filePath, task.params?.content || "Hello from Cade!");
        return { status: "success", message: `File created at ${filePath}` };
      }

      case "readFile": {
        const filePath = path.join(process.cwd(), task.params?.path || "output.txt");
        const content = fs.readFileSync(filePath, "utf8");
        return { status: "success", message: `File read successfully.`, content };
      }

      case "deleteFile": {
        const filePath = path.join(process.cwd(), task.params?.path || "output.txt");
        fs.unlinkSync(filePath);
        return { status: "success", message: `File deleted at ${filePath}` };
      }

      default:
        return { status: "error", message: `Unknown task type: ${task.type}` };
    }
  } catch (err: any) {
    return { status: "error", message: err.message };
  }
}
