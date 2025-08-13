/* eslint-disable import/no-commonjs */
document.addEventListener('DOMContentLoaded', async () => {
  const trackerTab = document.querySelector('.tab-content');
  if (!trackerTab) return;

  try {
    const res = await fetch('projects.json');
    const projects = await res.json();

    if (projects.length === 0) {
      trackerTab.innerHTML = '<p>No projects yet...</p>';
      return;
    }

    trackerTab.innerHTML = 
      <ul class="project-list">
        ${projects.map(p => 
          <li class="project-item" data-status="${p.status}">
            <span class="project-name">${p.name}</span>
            <span class="status ${p.status.toLowerCase().replace(/ /g,'-')}">
              ${p.status}
            </span>
            <button class="edit-btn">Request Edit</button>
          </li>
        `).join('')}
      </ul>
    `;

    trackerTab.querySelectorAll('.edit-btn').forEach((btn, idx) => {
      btn.addEventListener('click', () => {
        alert(\`Edit request submitted for: \${projects[idx].name}\`);
      });
    });
  } catch (err) {
    console.error("❌ Failed to load project data:", err);
    trackerTab.innerHTML = '<p style="color:red;">Error loading projects</p>';
  }
});
