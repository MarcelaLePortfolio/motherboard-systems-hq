// ESM script to onboard a new agent: creates per-agent memory JSON
// and optionally registers the agent in config/agents.json.
//
// Usage:
//   npx tsx scripts/_local/matilda_tasks/onboard_agent.mjs <Name> "<Role>"
//   npx tsx scripts/_local/matilda_tasks/onboard_agent.mjs Brandy "Copywriting Specialist" --config
//   npx tsx scripts/_local/matilda_tasks/onboard_agent.mjs   # (interactive prompts)
//
// Flags:
//   --config     Force add/update config/agents.json without prompting
//   --no-config  Skip touching config/agents.json
//
// Notes:
// - Works from any cwd; paths are resolved relative to this file.
// - Designed for Node ESM, executed via `npx tsx`.
//
// © Motherboard Systems HQ
import fs from 'fs';
import path from 'path';
import readline from 'readline';
import { fileURLToPath } from 'url';
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
// ---------- Small helpers ----------
function toKebabCase(str) {
    return String(str).trim().toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9\-]/g, '');
}
function toSnakeCase(str) {
    return String(str).trim().toLowerCase().replace(/\s+/g, '_').replace(/[^a-z0-9_]/g, '');
}
function ensureDirSync(p) {
    if (!fs.existsSync(p))
        fs.mkdirSync(p, { recursive: true });
}
function readJSONSafe(p) {
    try {
        if (!fs.existsSync(p))
            return null;
        const raw = fs.readFileSync(p, 'utf8');
        return JSON.parse(raw);
    }
    catch {
        return null;
    }
}
function writeJSONPretty(p, data) {
    ensureDirSync(path.dirname(p));
    fs.writeFileSync(p, JSON.stringify(data, null, 2) + '\n', 'utf8');
}
// ---------- Prompt helpers ----------
function makePrompt() {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
    const ask = (q) => new Promise((res) => rl.question(q, (ans) => res(ans.trim())));
    const close = () => rl.close();
    return { ask, close };
}
// ---------- Paths (relative to repo root inferred from this script) ----------
const MEMORY_DIR = path.resolve(__dirname, '../agent-runtime/memory');
const CONFIG_DIR = path.resolve(__dirname, '../../..', 'config');
const CONFIG_PATH = path.join(CONFIG_DIR, 'agents.json');
// ---------- CLI args & flags ----------
const args = process.argv.slice(2);
const flags = new Set(args.filter(a => a.startsWith('--')));
const positional = args.filter(a => !a.startsWith('--'));
let nameArg = positional[0];
let roleArg = positional[1];
const forceConfigAdd = flags.has('--config');
const forceConfigSkip = flags.has('--no-config');
function printUsage() {
    console.log(`\nOnboard a new agent\n--------------------\n` +
        `Usage:\n  npx tsx ${path.relative(process.cwd(), __filename)} <Name> "<Role>" [--config|--no-config]\n\n` +
        `Examples:\n  npx tsx ${path.relative(process.cwd(), __filename)} Brandy "Copywriting Specialist" --config\n  npx tsx ${path.relative(process.cwd(), __filename)}\n`);
}
// ---------- Core behaviors ----------
async function createMemoryFile(agentName, agentRole) {
    const fileSafe = toSnakeCase(agentName);
    const memPath = path.join(MEMORY_DIR, `${fileSafe}_chain_state.json`);
    const payload = {
        agent: agentName,
        role: agentRole,
        status: 'Idle',
        ts: 0
    };
    writeJSONPretty(memPath, payload);
    return memPath;
}
function upsertAgentsConfig(agentName, agentRole) {
    ensureDirSync(CONFIG_DIR);
    const existing = readJSONSafe(CONFIG_PATH);
    const entry = {
        name: agentName,
        role: agentRole,
        id: toKebabCase(agentName),
        created: new Date().toISOString()
    };
    let next;
    if (!existing) {
        next = { agents: [entry] };
    }
    else if (Array.isArray(existing)) {
        // Legacy shape: array only
        const filtered = existing.filter(a => (a?.name || a?.id) !== entry.name && (a?.id !== entry.id));
        next = [...filtered, entry];
    }
    else if (typeof existing === 'object') {
        const agents = Array.isArray(existing.agents) ? existing.agents : [];
        const filtered = agents.filter(a => (a?.name || a?.id) !== entry.name && (a?.id !== entry.id));
        next = { ...existing, agents: [...filtered, entry] };
    }
    else {
        next = { agents: [entry] };
    }
    writeJSONPretty(CONFIG_PATH, next);
    return CONFIG_PATH;
}
async function main() {
    const { ask, close } = makePrompt();
    try {
        if (!nameArg)
            nameArg = await ask('🤖 Enter new agent name: ');
        if (!nameArg) {
            console.error('❌ Agent name is required.');
            printUsage();
            return process.exit(1);
        }
        if (!roleArg)
            roleArg = await ask('💼 Enter agent role/description: ');
        if (!roleArg) {
            console.error('❌ Agent role is required.');
            printUsage();
            return process.exit(1);
        }
        // Create memory file
        const memPath = await createMemoryFile(nameArg, roleArg);
        console.log(`✅ Memory file created: ${memPath}`);
        // Determine config update
        let doConfig = forceConfigAdd ? true : forceConfigSkip ? false : null;
        if (doConfig === null) {
            const ans = (await ask('➕ Add to config/agents.json? (y/N): ')).toLowerCase();
            doConfig = ans === 'y' || ans === 'yes';
        }
        if (doConfig) {
            const cfgPath = upsertAgentsConfig(nameArg, roleArg);
            console.log(`✅ Config updated: ${cfgPath}`);
        }
        else {
            console.log('ℹ️ Skipped updating config/agents.json');
        }
        console.log('\n🎯 Onboarding complete.');
    }
    catch (err) {
        console.error(`❌ Failed: ${err?.message || err}`);
        process.exit(1);
    }
    finally {
        close();
    }
}
main();
