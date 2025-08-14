import fs from 'fs';
import path from 'path';
import { supabase } from '../../utils/supabaseClient';

const taskPath = path.resolve('scripts/_local/memory/effie_task.json');

async function readTask(): Promise<any | null> {
  // Try Supabase first
  try {
    const { data: state, error } = await supabase
      .from('agent_chain_state')
      .select('data')
      .eq('id', 'singleton')
      .single();

    if (error) throw error;

    const tasks = state?.data?.tasks;
    const effieTask = Array.isArray(tasks)
      ? tasks.find((t: any) => t.agent === 'effie')
      : null;

    if (effieTask) {
      console.log('☁️ Effie loaded task from Supabase');
      return effieTask;
    }
  } catch (err) {
    console.warn('⚠️ Supabase fetch failed, falling back to local');
  }

  // Fallback: local file
  try {
    const raw = fs.readFileSync(taskPath, 'utf8');
    console.log('📁 Effie loaded task from local file');
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

function clearLocalTaskFile() {
  try {
    fs.unlinkSync(taskPath);
    console.log('🧹 Effie cleared local fallback task file');
  } catch {}
}

function processTask(task: any) {
  if (!task?.type) return;

  switch (task.type) {
    case 'log':
      console.log(`📝 Effie received log: "\${task.payload}"`);
      break;
    default:
      console.log(`⚠️ Effie received unknown task type: "\${task.type}"`);
  }

  clearLocalTaskFile();
}

async function poll() {
  const task = await readTask();
  if (!task) return;

  processTask(task);
}

setInterval(() => poll().catch(console.error), 3000);
console.log('⚡ Effie Task Processor: Polling every 3 seconds with Supabase fallback...');
