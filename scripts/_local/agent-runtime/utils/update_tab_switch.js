import fs from 'fs';

const filePath = 'ui/dashboard/index.html';
let html = fs.readFileSync(filePath, 'utf-8');

// Enhance tab-switching to refresh Settings tab on click
html = html.replace(
  /document\.querySelectorAll\("\.tab"\)\.forEach\(tab => {[\s\S]*?}\);/,
  `document.querySelectorAll(".tab").forEach(tab => {
    tab.addEventListener("click", () => {
      document.querySelectorAll(".tab").forEach(t => t.classList.remove("active"));
      document.querySelectorAll(".tab-content").forEach(tc => tc.classList.remove("active"));
      tab.classList.add("active");
      const id = tab.dataset.tab + "-tab";
      document.getElementById(id).classList.add("active");

      // Auto-refresh settings tab
      if (id === "settings-tab" && typeof fetchSettings === "function") {
        fetchSettings();
      }
    });
  });`
);

fs.writeFileSync(filePath, html, 'utf-8');
console.log("✅ Tab-switching updated: Settings tab now refreshes dynamically via fetchSettings().");
