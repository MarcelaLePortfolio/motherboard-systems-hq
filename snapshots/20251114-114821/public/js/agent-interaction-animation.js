// <0001fafa> Phase 6.6.2 — Agent Interaction Animation (OPS Sync + Toggle)
const agents = ["Matilda", "Cade", "Effie"];
const colors = ["#ff66aa", "#ffaa33", "#66ccff"];
let animationInterval = null;

export function playAgentInteractionAnimation(syncEvent) {
  try {
    let container = document.getElementById("agentAnimation");
    if (!container) {
      container = document.createElement("div");
      container.id = "agentAnimation";
      container.style.display = "flex";
      container.style.justifyContent = "center";
      container.style.alignItems = "center";
      container.style.gap = "40px";
      container.style.padding = "20px";
      container.style.fontFamily = "monospace";
      container.style.transition = "opacity 0.5s ease";
      document.body.appendChild(container);
    }

    if (container.childNodes.length === 0) {
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
    }

    clearInterval(animationInterval);
    let index = 0;

    animationInterval = setInterval(() => {
      const els = document.querySelectorAll("#agentAnimation div");
      els.forEach((el, i) => {
        el.style.opacity = i === index ? "1" : "0.4";
        el.style.transform = i === index ? "scale(1.2)" : "scale(1)";
      });
      console.log(`🎬 Active Agent: ${agents[index]}`);
      index = (index + 1) % agents.length;
    }, 1500);

    // Optional OPS sync: pulse animation when reflection updates arrive
    if (syncEvent) {
      const el = document.querySelectorAll("#agentAnimation div")[syncEvent.agentIndex];
      if (el) {
        el.style.opacity = "1";
        el.style.transform = "scale(1.3)";
        setTimeout(() => {
          el.style.transform = "scale(1)";
        }, 600);
      }
    }

    // Toggle button for dashboard control
    if (!document.getElementById("toggleAnimation")) {
      const btn = document.createElement("button");
      btn.id = "toggleAnimation";
      btn.textContent = "⏸️ Pause Animation";
      btn.style.margin = "20px auto";
      btn.style.display = "block";
      btn.style.padding = "10px 15px";
      btn.onclick = () => {
        if (animationInterval) {
          clearInterval(animationInterval);
          animationInterval = null;
          btn.textContent = "▶️ Resume Animation";
        } else {
          playAgentInteractionAnimation();
          btn.textContent = "⏸️ Pause Animation";
        }
      };
      document.body.appendChild(btn);
    }

  } catch (err) {
    console.error("❌ Agent Interaction Animation error:", err);
  }
}

window.addEventListener("DOMContentLoaded", () => playAgentInteractionAnimation());
