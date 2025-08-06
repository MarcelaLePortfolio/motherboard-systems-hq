// ♻️ Memory Prune Script with dotenv for Supabase (7-day summarizer)

require('dotenv').config({ path: __dirname + '/.env' });
const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY;

if (!SUPABASE_URL || !SUPABASE_KEY) {
  console.error('❌ Missing Supabase environment variables.');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function pruneMemory() {
  console.log('🔎 Fetching rows older than 7 days...');
  const { data, error } = await supabase
    .from('cade_task_history')
    .select('*')
    .lt('inserted_at', new Date(Date.now() - 7*24*60*60*1000).toISOString());

  if (error) {
    console.error('❌ Error fetching old rows:', error.message);
    process.exit(1);
  }

  if (!data.length) {
    console.log('✅ No rows older than 7 days.');
    process.exit(0);
  }

  console.log(`Found ${data.length} old rows to summarize.`);

  for (const row of data) {
    const compactSummary = {
      id: row.id,
      date: row.inserted_at,
      status: row.status,
      output_file: row.output_file,
      steps: row.full_chain ? row.full_chain.map(t => t.type) : []
    };

    const { error: updateError } = await supabase
      .from('cade_task_history')
      .update({
        summary: compactSummary,
        full_chain: null
      })
      .eq('id', row.id);

    if (updateError) console.error(`⚠️ Failed to summarize row ${row.id}:`, updateError.message);
    else console.log(`♻️ Summarized row ${row.id}`);
  }

  console.log('✅ Pruning complete.');
}

pruneMemory();
