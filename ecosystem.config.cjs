module.exports = {
  apps: [
    {
      name: "cade",
      script: "scripts/agents/cade.launch.mjs",
      watch: true,
      autorestart: true,
      exec_mode: "fork",
      env: { NODE_ENV: "development" }
    }
  ]
};
