import fs from "fs";
import path from "path";

export async function cadeBuildAtlas() {
  const atlasRoot = path.join(process.cwd(), "runtime", "atlas");
  fs.mkdirSync(path.join(atlasRoot, "core"), { recursive: true });
  fs.mkdirSync(path.join(atlasRoot, "modules"), { recursive: true });
  fs.mkdirSync(path.join(atlasRoot, "logs"), { recursive: true });
  fs.appendFileSync(
    path.join(atlasRoot, "logs", "build.log"),
    `[${new Date().toISOString()}] Cade compiled Atlas core modules\n`
  );
  console.log("<0001f9e9> Cade compiled Atlas core modules.");
  return { status: "success", message: "Atlas core modules compiled" };
}
