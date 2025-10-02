<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>⚡ Motherboard Dashboard</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; background: #f7f7f7; }
    h1 { color: #333; }
    .card { background: #fff; padding: 15px; margin-bottom: 20px; border-radius: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background: #f2f2f2; }
    .status-online { color: green; font-weight: bold; }
    .status-offline { color: red; font-weight: bold; }
    .status-idle { color: orange; font-weight: bold; }
  </style>
</head>
<body>
  <h1>🖥️ Motherboard Dashboard</h1>

  <div class="card">
    <h2>Agent Status</h2>
    <table id="agents"></table>
  </div>

  <div class="card">
    <h2>Recent Tasks</h2>
    <table id="tasks"></table>
  </div>

  <div class="card">
    <h2>Recent Logs</h2>
    <table id="logs"></table>
  </div>

  <div class="card">
    <h2>Submit Task</h2>
    <form id="taskForm">
      <input type="text" id="command" placeholder="Enter command (e.g., dev:clean)" size="50" />
      <button type="submit">Run</button>
    </form>
    <pre id="taskResponse"></pre>
  </div>

</body>
</html>
