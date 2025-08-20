import { drizzle } from 'drizzle-orm/better-sqlite3';
import Database from 'better-sqlite3';
import { agentTasks } from '../../drizzle/schema';

const sqlite = new Database('motherboard.sqlite');
const db = drizzle(sqlite);

await db.insert(agentTasks).values([
  {
    agent: 'Cade',
    type: 'read file',
    status: 'Pending',
    content: 'memory/agent_chain_state.json',
    ts: new Date()
  },
  {
    agent: 'Cade',
    type: 'write file',
    status: 'Idle',
    content: 'memory/log.txt',
    ts: new Date()
  }
]);

console.log('✅ Seed data inserted into agent_tasks.');
