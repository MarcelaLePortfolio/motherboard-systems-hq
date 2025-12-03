module.exports = {
  apps: [
    {
      name: "reflections-stream",
      script: "reflections-stream/reflections_stream.py",
      interpreter: "python3",
      autorestart: true,
      watch: false,
      env: {
        PYTHONUNBUFFERED: "1",
      },
    },
    {
      name: "ops-stream",
      script: "ops-stream/ops_stream.py",
      interpreter: "python3",
      autorestart: true,
      watch: false,
      env: {
        PYTHONUNBUFFERED: "1",
      },
    },
  ],
};
