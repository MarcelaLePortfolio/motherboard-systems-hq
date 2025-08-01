document.addEventListener('DOMContentLoaded', () => {
  const trackerTab = document.querySelector('.tab-content');
  if (trackerTab && trackerTab.textContent.includes('Tab content placeholder')) {
    trackerTab.innerHTML = `
      <ul class="project-list">
        <li class="project-item">🚀 Launch dashboard UI</li>
        <li class="project-item">🤖 Connect Matilda to Ollama (llama3:8b)</li>
        <li class="project-item">📊 Implement smooth Project Tracker</li>
      </ul>
    `;
  }
});
