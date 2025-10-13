/* eslint-disable import/no-commonjs */
document.addEventListener('DOMContentLoaded', () => {
  const tabs = document.querySelectorAll('.tab');
  const sections = ['backlog', 'in-progress', 'completed'];

  function showSection(target) {
    sections.forEach(id => {
      const el = document.getElementById(`tracker-${id}`);
      if (el) el.style.display = (id === target) ? 'block' : 'none';
    });
  }

  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      const target = tab.dataset.target;
      showSection(target);
    });
  });

  showSection('backlog'); // Default tab
});
