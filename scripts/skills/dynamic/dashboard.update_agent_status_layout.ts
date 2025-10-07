import fs from "fs";
import { JSDOM } from "jsdom";

/**
 * Make Agent Status display horizontally using inline flex styling.
 */
export default async function run(params: any, _ctx: any): Promise<string> {
  const file = "public/dashboard.html";
  const html = fs.readFileSync(file, "utf8");
  const dom = new JSDOM(html);
  const d = dom.window.document;

  const agentHeader = Array.from(d.querySelectorAll("h2"))
    .find(h => /Agent\s+Status/i.test(h.textContent || ""));
  const section = agentHeader ? agentHeader.parentElement : null;

  if (!section) return "❌ Agent Status section not found.";

  section.setAttribute(
    "style",
    "display:flex; gap:1rem; align-items:center; flex-wrap:wrap;"
  );

  fs.writeFileSync(file, dom.serialize(), "utf8");
  return "✅ Agent Status section is now displayed horizontally.";
}
