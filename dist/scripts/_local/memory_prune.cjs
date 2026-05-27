"use strict";
require('dotenv').config({ path: __dirname + '/.env', override: true });
const { createClient } = require('@supabase/supabase-js');
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY;
console.log("🔹 URL:", SUPABASE_URL);
console.log("🔹 Key length:", SUPABASE_KEY?.length);
if (!SUPABASE_URL || !SUPABASE_KEY) {
    console.error('❌ Missing Supabase environment variables.');
    process.exit(1);
}
const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);
async function pruneMemory() {
    console.log("🔎 Fetching rows older than 7 days...");
    const { data, error } = await supabase
        .from('cade_task_history')
        .select('*')
        .lt('created_at', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString());
    if (error) {
        console.error('❌ Error fetching old rows:', error);
        process.exit(1);
    }
    console.log("✅ Fetched rows:", data.length);
}
pruneMemory();
