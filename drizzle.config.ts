import type { Config } from "drizzle-kit";

export default {
  schema: "./db/schema.index.ts",
  out: "./drizzle",
  dialect: "sqlite",
  dbCredentials: {
    url: "db/dev.db"
  }
} satisfies Config;
