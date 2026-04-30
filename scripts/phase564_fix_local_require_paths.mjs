import fs from "fs";
import path from "path";

const root = process.cwd();
const targets = ["server.mjs", "server/worker/phase26_task_worker.mjs"];
const ignored = new Set([".git", "node_modules", ".next", "dist", "_snapshots"]);

function walk(dir, acc = []) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (ignored.has(entry.name)) continue;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(full, acc);
    else acc.push(full);
  }
  return acc;
}

const allFiles = walk(root);

function resolveRequire(fromFile, requested) {
  const fromDir = path.dirname(path.resolve(root, fromFile));
  const base = path.resolve(fromDir, requested);
  const direct = [base, `${base}.mjs`, `${base}.js`, `${base}.cjs`];

  for (const candidate of direct) {
    if (fs.existsSync(candidate)) {
      let rel = path.relative(fromDir, candidate).split(path.sep).join("/");
      if (!rel.startsWith(".")) rel = `./${rel}`;
      return rel;
    }
  }

  const requestedBase = path.basename(requested);
  const matches = allFiles.filter((file) => {
    const parsed = path.parse(file);
    return parsed.name === requestedBase && [".mjs", ".js", ".cjs"].includes(parsed.ext);
  });

  if (matches.length !== 1) {
    throw new Error(`Unable to resolve ${requested} from ${fromFile}; matches=${matches.map(f => path.relative(root, f)).join(",") || "none"}`);
  }

  let rel = path.relative(fromDir, matches[0]).split(path.sep).join("/");
  if (!rel.startsWith(".")) rel = `./${rel}`;
  return rel;
}

for (const file of targets) {
  let src = fs.readFileSync(file, "utf8");

  src = src.replace(
    /import\s+\{\s*createRequire\s*\}\s+from\s+["']module["'];\nconst\s+require\s*=\s*createRequire\(import\.meta\.url\);\n?/g,
    ""
  );

  src = src.replace(/require\(["']([^"']+)["']\)/g, (match, requested) => {
    if (!requested.startsWith(".")) return match;
    return `require("${resolveRequire(file, requested)}")`;
  });

  if (src.includes("require(")) {
    src = `import { createRequire } from "module";\nconst require = createRequire(import.meta.url);\n${src}`;
  }

  fs.writeFileSync(file, src);
  console.log(`[fixed] ${file}`);
}
