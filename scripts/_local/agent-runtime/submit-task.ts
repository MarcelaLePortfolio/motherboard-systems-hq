/**
 * submit-task.ts
 * Post a task to memory/agent_chain_state.json without fragile heredocs.
 *
 * Usage examples:
 *   tsx scripts/_local/agent-runtime/submit-task.ts run_shell --cmd "echo hello"
 *   tsx scripts/_local/agent-runtime/submit-task.ts generate_file --path tmp/cade-proof.txt --content "hi"
 *   tsx scripts/_local/agent-runtime/submit-task.ts run_shell --id custom-123 --cmd "date"
 */

import * as fs from 'fs';
import * as fsp from 'fs/promises';
import * as path from 'path';

type Params = Record<string, string | number | boolean>;
const PROJECT_ROOT = process.cwd();
const STATE_FILE = path.join(PROJECT_ROOT, 'memory', 'agent_chain_state.json');

function parseArgs(argv: string[]) {
  const out: Params = {};
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith('--')) {
      const k = a.slice(2);
      const v = argv[i + 1] && !argv[i + 1].startsWith('--') ? argv[++i] : 'true';
      out[k] = v;
    } else if (!out['_']) {
      out['_'] = a;
    } else {
if (!Array.isArray((out as any)["_args"])) { (out as any)["_args"] = [] as string[]; } ((out as any)["_args"] as string[]).push(String(a));
    }
  }
  return out;
}

async function ensureDir(p: string) {
  await fsp.mkdir(p, { recursive: true }).catch(() => {});
}

async function writeJson(file: string, data: any) {
  await ensureDir(path.dirname(file));
  const tmp = `${file}.tmp-${Date.now()}`;
  await fsp.writeFile(tmp, JSON.stringify(data, null, 2), 'utf8');
  await fsp.rename(tmp, file);
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const type = String(args._ || '');
  if (!type) {
    console.error('Usage: tsx scripts/_local/agent-runtime/submit-task.ts <run_shell|generate_file> [--id ID] [--cmd "echo hi"] [--path FILE --content TEXT]');
    process.exit(2);
  }

  const id = String(args.id || `task-${Date.now()}`);
  const ts = Math.floor(Date.now() / 1000);

  let params: Record<string, any> = {};
  if (type === 'run_shell') {
    const cmd = String(args.cmd || args.command || '');
    if (!cmd) {
      console.error('run_shell requires --cmd "<command>"');
      process.exit(2);
    }
    params = { command: cmd };
  } else if (type === 'generate_file') {
    const filePath = String(args.path || args.file || '');
    const content = String(args.content ?? '');
    if (!filePath) {
      console.error('generate_file requires --path "<relative/file.txt>"');
      process.exit(2);
    }
    const abs = path.resolve(PROJECT_ROOT, filePath);
    if (!abs.startsWith(PROJECT_ROOT)) {
      console.error(`Refusing to write outside project root: ${filePath}`);
      process.exit(2);
    }
    params = { path: filePath, content };
  } else {
    console.error(`Unknown task type "${type}". Supported: run_shell, generate_file`);
    process.exit(2);
  }

  const stateBody = {
    agent: 'Matilda',
    status: 'Delegating',
    ts,
    task: { id, type, params }
  };

  await writeJson(STATE_FILE, stateBody);
  console.log(`✅ Wrote task ${id}: ${type}`);
  console.log(`→ ${path.relative(PROJECT_ROOT, STATE_FILE)}`);
}

main().catch(err => {
  console.error('❌ submit-task failed:', err?.message || err);
  process.exit(1);
});
