import fs from "fs";
import { JSDOM } from "jsdom";

export default async function run(params: any, _ctx: any): Promise<string> {
  const file = "public/dashboard.html";
  const html = fs.readFileSync(file, "utf8");
  const dom = new JSDOM(html);
  const d = dom.window.document;

  const moveTxt = String(params.move || "Agent Status").toLowerCase();
  const beforeTxt = String(params.before || "Recent Tasks").toLowerCase();

  const findH2 = (txt: string) =>
    Array.from(d.querySelectorAll("h2"))
      .find(h => (h.textContent || "").toLowerCase().includes(txt));

  const sectionRoot = (h: Element | null) =>
    (h && (h.closest("section") || h.parentElement)) as HTMLElement | null;

  const moveH2 = findH2(moveTxt);
  const beforeH2 = findH2(beforeTxt);
  const A = sectionRoot(moveH2);
  const B = sectionRoot(beforeH2);

  if (!A || !B) {
    return `❌ Could not find sections for "${params.move}" or "${params.before}"`;
  }
  if (A === B) {
    return "ℹ️ Sections are the same; nothing to move.";
  }

  B.parentElement?.insertBefore(A, B);
  fs.writeFileSync(file, dom.serialize(), "utf8");
  return `✅ Moved "${params.move}" above "${params.before}".`;
}
