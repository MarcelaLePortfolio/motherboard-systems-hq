import type { Config } from 'drizzle-kit';

export default {
  schema: ['./db/tasks.ts', './db/audit.ts', './db/output.ts'], // only include real schema files
  out: './drizzle',
  dialect: 'sqlite',
  dbCredentials: {
    url: './db/dev.db',
  },
} satisfies Config;
