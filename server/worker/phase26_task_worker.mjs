import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { Pool } from "pg";
import { emitTaskEvent } from "../task_events_emit.mjs";
function sleep(ms){return new Promise(r=>setTimeout(r,ms));}
function readSqlFile(p){const a=path.isAbsolute(p)?p:path.join(process.cwd(),p);return fs.readFileSync(a,"utf-8");}

const POSTGRES_URL=process.env.POSTGRES_URL;
if(!POSTGRES_URL) throw new Error("POSTGRES_URL required");
const TICK_MS=Number(process.env.PHASE26_TICK_MS||500);
const BACKOFF_BASE_MS=Number(process.env.WORKER_BACKOFF_BASE_MS||2000);
const owner=process.env.WORKER_OWNER||`worker-${process.pid}`;
const CLAIM_ONE_PATH=process.env.PHASE32_CLAIM_ONE_SQL||process.env.PHASE27_CLAIM_ONE_SQL;
const MARK_SUCCESS_PATH=process.env.PHASE32_MARK_SUCCESS_SQL||process.env.PHASE27_MARK_SUCCESS_SQL;
const MARK_FAILURE_PATH=process.env.PHASE32_MARK_FAILURE_SQL||process.env.PHASE27_MARK_FAILURE_SQL;

if(!CLAIM_ONE_PATH||!MARK_SUCCESS_PATH||!MARK_FAILURE_PATH)
  throw new Error("PHASE32_* or PHASE27_* SQL paths required");
const CLAIM_ONE_SQL=readSqlFile(CLAIM_ONE_PATH);
const MARK_SUCCESS_SQL=readSqlFile(MARK_SUCCESS_PATH);
const MARK_FAILURE_SQL=readSqlFile(MARK_FAILURE_PATH);
const pool=new Pool({connectionString:POSTGRES_URL});
async function claimOne(c,run_id){
  const r=await c.query(CLAIM_ONE_SQL,[run_id,owner]);
  return r.rows?.[0]||null;
}
async function markSuccess(c,id){
  const r=await c.query(MARK_SUCCESS_SQL,[id]);
  return r.rows?.[0]||null;
}
async function markFailure(c,id,e){
  const r=await c.query(MARK_FAILURE_SQL,[id,String(e||"")]);
  return r.rows?.[0]||null;
}
async function loop(){
  let backoff=BACKOFF_BASE_MS;
  while(true){
    const run_id=`run-${Date.now()}-${Math.random().toString(16).slice(2)}`;
    try{
      const c=await pool.connect();
      try{
        await c.query("BEGIN");
        const task=await claimOne(c,run_id);
        await c.query("COMMIT");
        if(!task){c.release();await sleep(TICK_MS);backoff=BACKOFF_BASE_MS;continue;}
        await emitTaskEvent({pool,kind:"task.running",task_id:task.id,run_id:task.run_id||run_id,actor:owner,
          payload:{ts:Date.now(),attempts:task.attempts,max_attempts:task.max_attempts}});
        const done=await markSuccess(c,task.id);
        if(done){
          await emitTaskEvent({pool,kind:"task.completed",task_id:done.id,run_id:done.run_id||run_id,actor:owner,
            payload:{ts:Date.now(),attempts:done.attempts,max_attempts:done.max_attempts}});
        }
        c.release();backoff=BACKOFF_BASE_MS;
      }catch(e){try{await pool.query("ROLLBACK");}catch{} throw e;}
    }catch(e){console.error("[worker] loop error",e);await sleep(backoff);backoff=Math.min(backoff*2,30000);}
  }
}
loop().catch(e=>{console.error("[worker] fatal",e);process.exit(1);});
