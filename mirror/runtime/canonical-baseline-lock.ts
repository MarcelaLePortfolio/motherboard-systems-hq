export const MATILDA_BASELINE = {
  runtime: "matilda_runtime.mjs",
  mesh: "mirror/mesh/registry.ts",
  process_manager: "pm2-single-instance",
  execution_model: "dist-runtime-only",
  status: "LOCKED",
  notes: "Stable Matilda baseline captured after recovery from module resolution drift and PM2 duplication.",
  locked_at: Date.now()
};
