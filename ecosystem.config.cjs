module.exports = {
  apps: [
    {
      name: "cade",
      script: "./scripts/agents_full/run_cade.sh",
      watch: false,
      exec_mode: "fork",
      instances: 1
    },
    {
      name: "matilda",
      script: "./scripts/agents_full/run_matilda.sh",
      watch: false,
      exec_mode: "fork",
      instances: 1
    },
    {
      name: "effie",
      script: "./scripts/agents_full/run_effie.sh",
      watch: false,
      exec_mode: "fork",
      instances: 1
    }
  ]
};