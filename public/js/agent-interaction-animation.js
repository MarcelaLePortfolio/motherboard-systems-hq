// <0001faf9> Phase 6.6.1 — Agent Interaction Animation (Basic Loop)
const agents = ["Matilda", "Cade", "Effie"];
const colors = ["#ff66aa", "#ffaa33", "#66ccff"];

export function playAgentInteractionAnimation() {
  try {
    const container = document.createElement("div");
    container.id = "agentAnimation";
    container.style.display = "flex";
    container.style.justifyContent = "center";
    container.style.alignItems = "center";
    container.style.gap = "40px";
    container.style.padding = "20px";
    container.style.fontFamily = "monospace";
    document.body.appendChild(container);

    agents.forEach((agent, i) => {
      const el = document.createElement("div");
      el.textContent = agent;
      el.style.padding = "10px 20px";
      el.style.borderRadius = "8px";
      el.style.background = "#222";
      el.style.color = colors[i];
      el.style.border = `2px solid ${colors[i]}`;
      el.style.transition = "transform 0.4s ease, opacity 0.4s ease";
      container.appendChild(el);
    });

    let index = 0;
    setInterval(() => {
      const els = document.querySelectorAll("#agentAnimation div");
      els.forEach((el, i) => {
        el.style.opacity = i === index ? "1" : "0.4";
        el.style.transform = i === index ? "scale(1.2)" : "scale(1)";
      });
      console.log(`🎬 Active Agent: ${agents[index]}`);
      index = (index + 1) % agents.length;
    }, 1500);
  } catch (err) {
    console.error("❌ Agent Interaction Animation error:", err);
  }
}

window.addEventListener("DOMContentLoaded", playAgentInteractionAnimation);
