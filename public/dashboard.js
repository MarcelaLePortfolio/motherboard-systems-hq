console.log("🧠 dash.js loaded");

// DEBUG CHECKPOINTS
document.querySelectorAll(".agent").forEach((el, i) => {
  console.log(`🔹 Agent[${i}]: ${el.textContent.trim()}`);
  const dot = el.querySelector("span");
  if (dot) {
    dot.style.backgroundColor = "gray"; // temporary default state
  }
});
