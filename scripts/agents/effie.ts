import fs from "fs";
import path from "path";

export async function effieRegisterAtlas() {
  const atlasRoot = path.join(process.cwd(), "runtime", "atlas");
  const registryPath = path.join(atlasRoot, "logs", "registry.log");
  fs.mkdirSync(path.dirname(registryPath), { recursive: true });
  fs.appendFileSync(
    registryPath,
    `[${new Date().toISOString()}] Effie registered Atlas runtime in system index\n`
  );
  console.log("⚙️ Effie registered Atlas runtime successfully.");
  return { status: "registered", message: "Atlas runtime indexed" };
}
