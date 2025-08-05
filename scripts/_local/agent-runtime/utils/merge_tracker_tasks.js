import fs from 'fs';

const filePath = 'ui/dashboard/index.html';
let html = fs.readFileSync(filePath, 'utf-8');

// Replace tracker-tab content
html = html.replace(
  /<div class="tab-content active" id="tracker-tab">[\s\S]*?<div class="tab-content" id="tasks-tab">/,
  `<div class="tab-content active" id="tracker-tab">
    <h3>Project Tracker</h3>
    <div id="project-tracker-log">
      <div class="task in-progress">Initializing tracker simulation...</div>
    </div>
  </div>
  <div class="tab-content" id="tasks-tab">`
);

// Replace tasks-tab content up to settings-tab
html = html.replace(
  /<div class="tab-content" id="tasks-tab">[\s\S]*?<div class="tab-content" id="settings-tab">/,
  `<div class="tab-content" id="tasks-tab">
    <h3>Task History</h3>
    <div id="task-history">
      <p>No tasks logged yet.</p>
    </div>
  </div>
  <div class="tab-content" id="settings-tab">`
);

// Ensure the simulation script exists or add it at the bottom
if (!html.includes('project-tracker-log')) {
  console.error("❌ Could not find project-tracker-log insertion point. Aborting.");
  process.exit(1);
}

if (!html.includes('Tracker simulation merged')) {
  html = html.replace(
    /<\/body>\s*<\/html>/,
    `<script>
    // Tracker simulation
    const trackerLog = document.getElementById("project-tracker-log");
    let trackerCounter = 0;
    setInterval(() => {
      trackerCounter++;
      const entry = document.createElement("div");
      entry.className = "task in-progress";
      entry.textContent = \`Simulation event #\${trackerCounter}\`;
      trackerLog.appendChild(entry);
      if (trackerLog.children.length > 6) trackerLog.removeChild(trackerLog.children[0]);
    }, 3000);

    // Task History simulation
    const taskHistory = document.getElementById("task-history");
    let taskCounter = 0;
    setInterval(() => {
      taskCounter++;
      const p = document.createElement("p");
      p.textContent = \`Task \${taskCounter} completed successfully.\`;
      taskHistory.appendChild(p);
      if (taskHistory.children.length > 10) taskHistory.removeChild(taskHistory.children[0]);
    }, 5000);

    console.log("✅ Tracker simulation merged");
    </script>
    </body>
    </html>`
  );
}

fs.writeFileSync(filePath, html, 'utf-8');
console.log("✅ Tracker and Tasks merged safely. Settings tab untouched.");
