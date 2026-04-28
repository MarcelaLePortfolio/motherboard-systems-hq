module.exports = {
  apps: [
    {
      name: "matilda",
      script: "dist/scripts/_local/agent-runtime/matilda_runtime.mjs",
      interpreter: "node",
      instances: 1,
      exec_mode: "fork",
      watch: false,
      autorestart: true,
      max_restarts: 10,
      env: {
        NODE_ENV: "production",
        MATILDA_PORT: 3001
      }
    }
  ]
};
