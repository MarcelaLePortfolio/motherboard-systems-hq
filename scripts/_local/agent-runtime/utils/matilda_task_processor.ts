import fs from 'fs';
import path from 'path';
import { supabase } from '../../utils/supabaseClient';

const fallbackPath = path.resolve('memory/agent_chain_state.json');

async function readChainState(): Promise<any> {
  try {
    const { data, error } = await supabase
      .from('agent_chain_state')
      .select('data')
      .eq('id', 'singleton')
      .single();

    if (error || !data?.data) throw error;
    console.log('☁️ Matilda loaded chain state from Supabase');
    return data.data;
  } catch {
    try {
      const raw = fs.readFileSync(fallbackPath, 'utf8');
      console.log('📁 Matilda loaded chain state from local fallback');
      return JSON.parse(raw);
    } catch {
      return null;
    }
  }
}

function writeAgentTask(agent: string, task: any) {
  const agentPath = path.resolve(`scripts/_local/memory/${agent}_task.json`);
  if (fs.existsSync(agentPath)) {
    console.log(`⚠️ Skipping: ${agent}_task.json already exists`);
    return;
  }

  fs.writeFileSync(agentPath, JSON.stringify(task, null, 2), 'utf8');
  console.log(`📤 Matilda wrote task for ${agent}`);
}

async function processTasks() {
  const state = await readChainState();
  const tasks = state?.tasks;

  if (!Array.isArray(tasks)) {
    console.log('ℹ️ No tasks to delegate yet');
    return;
  }

  for (const task of tasks) {
    if (!task?.agent || !task?.action) continue;

    writeAgentTask(task.agent, {
      type: task.action,
      payload: task.payload || null,
      from: 'matilda',
      taskId: task.id,
    });
  }
}

processTasks();
setInterval(processTasks, 3000);
console.log('⚡ Matilda Task Processor: Polling with Supabase fallback...');


export function startMatildaTaskProcessor() {
  processTasks();
  setInterval(processTasks, 3000);
  console.log('⚡ Matilda Task Processor: Polling with Supabase fallback...');
}
