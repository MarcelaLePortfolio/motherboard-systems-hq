import fs from "fs";
import { JSDOM } from "jsdom";

export default async function run(params: {}, ctx: {}): Promise<string> {
  const filePath = "public/dashboard.html";
  const html = fs.readFileSync(filePath, "utf8");
  const dom = new JSDOM(html);
  const doc = dom.window.document;

  // Locate the <h2> headers explicitly by their visible text
  const headers = Array.from(doc.querySelectorAll("h2"));
  const chatHeader = headers.find(h => (h.textContent || "").includes("Chat with Assistant"));
  const agentHeader = headers.find(h => (h.textContent || "").includes("Agent Status"));

  if (!chatHeader || !agentHeader) {
    return "❌ Could not locate Chat or Agent Status header text.";
  }

  // Find the container elements (the nearest parent <div> or <section>)
  const chatSection = chatHeader.closest("section, div") || chatHeader.parentElement;
  const agentSection = agentHeader.closest("section, div") || agentHeader.parentElement;

  if (!chatSection || !agentSection) {
    return "❌ Could not resolve Chat or Agent Status containers.";
  }

  // Move Agent Status section directly below Chat section
  chatSection.insertAdjacentElement("afterend", agentSection);

  fs.writeFileSync(filePath, dom.serialize(), "utf8");
  return "✅ Agent Status section moved below chatbot using DOM-aware logic.";
}
