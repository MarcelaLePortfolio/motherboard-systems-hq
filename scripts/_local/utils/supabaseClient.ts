import { createClient } from '@supabase/supabase-js';

let supabaseInstance;

export function getSupabaseClient() {
  if (!supabaseInstance) {
    const url = process.env.SUPABASE_URL;
    const key = process.env.SUPABASE_ANON_KEY;

    if (!url || !key) {
      throw new Error('Supabase URL or Key is missing from environment variables.');
    }

    supabaseInstance = createClient(url, key);
  }

  return supabaseInstance;
}
