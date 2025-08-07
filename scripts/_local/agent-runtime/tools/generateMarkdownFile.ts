import fs from "fs";
import path from "path";

export function generateMarkdownFile(filename: string, content: string) {
  const outputDir = path.join(__dirname, "../../../outputs");
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  const filePath = path.join(outputDir, filename);
  fs.writeFileSync(filePath, content, "utf8");
  console.log(`✅ Generated markdown file at: ${filePath}`);
}
