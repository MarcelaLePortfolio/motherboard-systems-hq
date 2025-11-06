// scripts/ops/create-entity.ts
// Universal constructor: builds agents, apps, or generic projects with hidden staging + progressive reveal.
import fs from "fs";
import path from "path";

type CreateOptions = {
  name: string;                 // e.g. "Atlas", "Brandy", "BeautyAndTheBarPortal"
  kind?: "agent" | "app" | "workspace" | "project"; // what we are creating
  mode: "demo" | "live";        // demo = visuals only, live = files + DB
  paceMs?: number;              // reveal pacing
  targetDir?: string;           // override destination
  reflectionsPath?: string;
  statusPath?: string;
};

function ensureDir(p: string) { fs.mkdirSync(p, { recursive: true }); }

function appendReflection(p: string, line: string) {
  let rows: any[] = [];
  try { rows = JSON.parse(fs.readFileSync(p, "utf8")); } catch {}
  const now = new Date().toISOString();
  rows.unshift({ id: `entity-${Date.now()}`, content: line, created_at: now });
  rows = rows.slice(0, 50);
  fs.writeFileSync(p, JSON.stringify(rows, null, 2), "utf8");
}

function writeStatus(p: string, label: string, seq: string[], idx: number) {
  const now = Math.floor(Date.now() / 1000);
  const steps = seq.slice(0, idx + 1).map((s, i) => ({
    t: now - (idx - i),
    step: s,
    detail: i === idx ? "active" : "ok"
  }));
  fs.writeFileSync(p, JSON.stringify({
    name: label,
    status: idx + 1 < seq.length ? "creating" : "online",
    sequence: steps,
    updated_at: now
  }, null, 2), "utf8");
}

function walkFiles(root: string): string[] {
  const out: string[] = [];
  const rec = (p: string) => {
    for (const e of fs.readdirSync(p, { withFileTypes: true })) {
      const full = path.join(p, e.name);
      if (e.isDirectory()) rec(full); else out.push(full);
    }
  };
  rec(root);
  return out.sort();
}

function writeTemplateSet(stagingDir: string, name: string, kind: string) {
  ensureDir(stagingDir);
  const header = `# ${name}\nThis ${kind} was scaffolded live by Atlas.\n`;
  const base = {
    [path.join(stagingDir, "README.md")]: header,
    [path.join(stagingDir, `${kind}.config.json`)]: JSON.stringify({
      name, kind, version: "0.1.0", created_at: new Date().toISOString()
    }, null, 2)
  };
  const kindFiles: Record<string, string> = {};
  if (kind === "agent") {
    kindFiles[path.join(stagingDir, "src/index.ts")] = 
      `export function ${name.toLowerCase()}Agent(){console.log("${name} agent online.");}`;
  } else if (kind === "app") {
    kindFiles[path.join(stagingDir, "src/App.tsx")] =
      `export default function ${name}App(){return <div>${name} app loaded.</div>}`;
  } else if (kind === "workspace") {
    kindFiles[path.join(stagingDir, "notes/setup.md")] =
      `Workspace setup guide for ${name}.`;
  } else {
    kindFiles[path.join(stagingDir, "src/main.ts")] =
      `console.log("${name} project initialized.");`;
  }
  for (const [fp, content] of Object.entries({...base, ...kindFiles})) {
    ensureDir(path.dirname(fp)); fs.writeFileSync(fp, content, "utf8");
  }
}

async function progressiveReveal(stagingDir: string, targetDir: string, paceMs: number) {
  ensureDir(targetDir);
  for (const src of walkFiles(stagingDir)) {
    const rel = path.relative(stagingDir, src);
    const dest = path.join(targetDir, rel);
    ensureDir(path.dirname(dest));
    fs.copyFileSync(src, dest);
    await new Promise(r => setTimeout(r, paceMs));
  }
}

function registerEntity(name: string, kind: string) {
  try {
    const Database = require("better-sqlite3");
    const db = new Database(path.join(process.cwd(), "db", "main.db"));
    db.prepare(`
      CREATE TABLE IF NOT EXISTS entities_status (
        id INTEGER PRIMARY KEY,
        name TEXT UNIQUE,
        kind TEXT,
        status TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )`).run();
    db.prepare(`
      INSERT INTO entities_status (name, kind, status)
      VALUES (@name, @kind, @status)
      ON CONFLICT(name) DO UPDATE SET status=excluded.status
    `).run({ name, kind, status: "online" });
  } catch (err) {
    console.error("Entity registration skipped:", err?.message || err);
  }
}

export async function createEntity(opts: CreateOptions) {
  const name = opts.name;
  const kind = opts.kind || "project";
  const paceMs = opts.paceMs ?? 1000;
  const targetDir = opts.targetDir ?? path.join("projects", name);
  const reflectionsPath = opts.reflectionsPath ?? path.join("public", "tmp", "reflections.json");
  const statusPath = opts.statusPath ?? path.join("public", "tmp", `${name.toLowerCase()}-status.json`);

  ensureDir(path.dirname(reflectionsPath));
  ensureDir(path.dirname(statusPath));

  const sequence = [
    `Bootstrapping ${kind} ${name}`,
    "Validating blueprint",
    "Preparing templates",
    "Progressive reveal to workspace",
    "Finalizing configuration",
    `${name} Online`
  ];

  const stamp = new Date().toISOString().replace(/[:.]/g, "-");
  const stagingDir = path.join(".builds", `${name}-${stamp}`);
  writeTemplateSet(stagingDir, name, kind);

  for (let i = 0; i < sequence.length; i++) {
    writeStatus(statusPath, name, sequence, i);
    appendReflection(reflectionsPath, `🎞️ [${name}] ${sequence[i]}…`);
    if (opts.mode === "live" && i === 3) {
      await progressiveReveal(stagingDir, targetDir, paceMs);
    }
    await new Promise(r => setTimeout(r, paceMs));
  }

  if (opts.mode === "live") registerEntity(name, kind);
}
