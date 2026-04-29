import fs from "node:fs";
import path from "path";

export async function cadeCreateWebpage(filename: string, htmlContent: string) {
  const filePath = path.join(process.cwd(), "public", filename);
  fs.writeFileSync(filePath, htmlContent, "utf8");
  console.log(`🧱 Cade created webpage → ${filePath}`);
  return { status: "success", path: filePath };
}
