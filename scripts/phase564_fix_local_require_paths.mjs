import fs from "fs";
import path from "path";

const root = process.cwd();

const files = [
  "server.mjs",
  "server/worker/phase26_task_worker.mjs",
];

function resolveLocalRequire(fromFile, requested) {
  const fromDir = path.dirname(path.resolve(root, fromFile));
  const base = path.resolve(fromDir, requested);

  const candidates = [
    base,
    `${base}.mjs`,
    `${base}.js`,
    `${base}.cjs`,
    path.join(base, "index.mjs"),
    path.join(base, "index.js"),
    path.join(base, "index.cjs"),
  ];

  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) {
      let rel = path.relative(fromDir, candidate).split(path.sep).join("/");
      if (!rel.startsWith(".")) rel = `./${rel}`;
      return rel;
    }
  }

  throw new Error(`Unable to resolve ${requested} from ${fromFile}`);
}

for (const file of files) {
  let src = fs.readFileSync(file, "utf8");

  src = src.replace(
    /import\s+\{\s*createRequire\s*\}\s+from\s+["']module["'];\nconst\s+require\s*=\s*createRequire\(import\.meta\.url\);\n?/g,
    ""
  );

  src = src.replace(/require\(["']([^"']+)["']\)/g, (match, requested) => {
    if (!requested.startsWith(".")) return match;
    return `require("${resolveLocalRequire(file, requested)}")`;
  });

  if (src.includes("require(")) {
    src = `import { createRequire } from "module";\nconst require = createRequire(import.meta.url);\n${src}`;
  }

  fs.writeFileSync(file, src);
  console.log(`[fixed] ${file}`);
}
