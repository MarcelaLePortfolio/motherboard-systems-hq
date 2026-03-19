import fs from "node:fs";

const target = "public/dashboard.html.bad_structure";
const source = fs.readFileSync(target, "utf8");

const oldBlock = String.raw`    async function updatePanel(id, endpoint) {
      const el = document.getElementById(id);
      if (!el) return;
      try {
        const res = await fetch(endpoint);
        const text = await res.text();
        el.textContent = text;
      } catch (err) {
        el.textContent = "Error loading panel.";
      }
    }`;

const newBlock = String.raw`    async function updatePanel(id, endpoint) {
      const el = document.getElementById(id);
      if (!el) return;
      try {
        const res = await fetch(endpoint);
        const contentType = res.headers.get("content-type") || "";

        if (contentType.includes("application/json")) {
          const json = await res.json();

          if (
            id === "system-health-content" &&
            json &&
            typeof json === "object" &&
            typeof json.situationSummary === "string"
          ) {
            const {
              situationSummary,
              ...rest
            } = json;

            el.textContent =
              JSON.stringify(rest, null, 2) +
              "\\n\\nSITUATION SUMMARY\\n" +
              situationSummary;

            return;
          }

          el.textContent = JSON.stringify(json, null, 2);
          return;
        }

        const text = await res.text();
        el.textContent = text;
      } catch (err) {
        el.textContent = "Error loading panel.";
      }
    }`;

if (!source.includes(oldBlock)) {
  throw new Error("Target updatePanel block not found");
}

const updated = source.replace(oldBlock, newBlock);
fs.writeFileSync(target, updated);
