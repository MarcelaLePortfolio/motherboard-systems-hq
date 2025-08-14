/* eslint-disable import/no-commonjs */
// ✅ Fallback Agent Dot Injection via Name Match
const agentStatusMap = {
  matilda: { label: "Running", color: "green" },
  cade: { label: "Error", color: "red" },
  effie: { label: "Stopped", color: "gray" },
};

document.querySelectorAll(".agent").forEach(agentDiv => {
  const labelText = agentDiv.textContent.toLowerCase();
  for (const [name, { label, color }] of Object.entries(agentStatusMap)) {
    if (labelText.includes(name)) {
      const dot = agentDiv.querySelector("span");
      if (dot) {
        dot.style.backgroundColor = color;
        agentDiv.title = label;
        console.log(`✅ ${name} dot painted ${color}`);
      }
    }
  }
});
