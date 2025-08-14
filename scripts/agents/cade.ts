import { getSupabaseClient } from '../_local/utils/supabaseClient';
const supabase = getSupabaseClient();

export async function cadeCommandRouter(command: string, args: any = {}): Promise<any> {
  switch (command) {
    case 'start full task delegation cycle': {
      const { data: existing, error } = await supabase
        .from('agent_chain_state')
        .select('data')
        .eq('id', 'singleton')
        .single();

      const newState = {
        ...(existing?.data || {}),
        tasks: [
          { id: 'T1', agent: 'effie', action: 'log', payload: 'Hello from Cade via Supabase.' }
        ]
      };

      const { error: upsertError } = await supabase
        .from('agent_chain_state')
        .upsert({ id: 'singleton', data: newState });

      if (upsertError) return { status: 'error', message: upsertError.message };
      return { status: 'success', message: '✅ Chain state written to Supabase' };
    }

    default:
      return { status: 'error', message: `❌ Unknown command "${command}"` };
  }
}
