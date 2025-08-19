// PM2 ecosystem file for all agents (ESM)
export default {
  apps: [
    {
      name: "cade",
      script: "./scripts/agents_full/cade.ts",
      interpreter: "tsx",
      env: {
        DOTENV_CONFIG_PATH: ".env.runtime",
        SUPABASE_URL: "https://your-project.supabase.co",
        SUPABASE_KEY: "your-secret-key",
      },
    },
    {
      name: "matilda",
      script: "./scripts/agents_full/matilda.ts",
      interpreter: "tsx",
      env: {
        DOTENV_CONFIG_PATH: ".env.runtime",
        SUPABASE_URL: "https://your-project.supabase.co",
        SUPABASE_KEY: "your-secret-key",
      },
    },
    {
      name: "effie",
      script: "./scripts/agents_full/effie.ts",
      interpreter: "tsx",
      env: {
        DOTENV_CONFIG_PATH: ".env.runtime",
        SUPABASE_URL: "https://jywedbwwaabdotfcsupw.supabase.co",
        SUPABASE_KEY: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5d2VkYnd3YWFiZG90ZmNzdXB3Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDUxMjczMSwiZXhwIjoyMDcwMDg4NzMxfQ.JcagrlH7jw6c0SK1gJHK8X3wW9lyxVZo4XOWGWtgwoo",
      },
    },
  ],
};
