const { enforceWorkerRetryContract } = require('./worker_retry_enforcer');
import process from "process";

if (!process.env.POSTGRES_URL) {
  process.env.POSTGRES_URL = process.env.DATABASE_URL;
}

if (!process.env.DATABASE_URL) {
  process.env.DATABASE_URL = process.env.POSTGRES_URL;
}

console.log("[env-fix] POSTGRES_URL:", !!process.env.POSTGRES_URL);
