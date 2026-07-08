
import fs from "fs";

import path from "path";

export function createFile(filename: string, content: string) {

  const filePath = path.join(process.cwd(), filename);

  fs.writeFileSync(filePath, content ?? "");

  return filePath;

}

export function updateFile(filename: string, content: string) {

  const filePath = path.join(process.cwd(), filename);

  fs.writeFileSync(filePath, content ?? "");

  return filePath;

}

export function deleteFile(filename: string) {

  const filePath = path.join(process.cwd(), filename);

  if (fs.existsSync(filePath)) fs.unlinkSync(filePath);

  return filePath;

}

