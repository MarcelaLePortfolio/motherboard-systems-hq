// ♻️ Memory Pruner – Condenses Cade task history older than 7 days
// <0051cade> Summarizes old entries instead of deleting

const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY;

if (!SUPABASE_URL || !SUPABASE_KEY) {
  console.error('❌ Missing Supabase environment variables.');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function pruneMemory() {
  const sevenDaysAgo = new Date();
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

  console.log(`�� Pruning entries older than ${sevenDaysAgo.toISOString()}...`);

  const { data, error } = await supabase
    .from('cade_task_history')
    .select('id, inserted_at, full_chain, summary, output_file, status')
    .lt('inserted_at', sevenDaysAgo.toISOString());

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
