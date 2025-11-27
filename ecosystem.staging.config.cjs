module.exports = {
  apps: [
    {
      name: "reflection-sse-server",
      namespace: "main-staging",
      script: "scripts/_local/route-loader/reflection-sse-server.ts",
      interpreter: "tsx",
      autorestart: true,
      watch: false,
      env: {
        NODE_ENV: "development",
        PORT: 3101
      }
    }
  ]
};
