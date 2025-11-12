import express, { Request, Response } from "express";
const router = express.Router();







import { sqlite } from "../db/client";
import { cadeCreateWebpage } from "../scripts/agents/cade-create-webpage.js";


  const instructionRaw = req.body?.instruction || "";
  const instruction = String(instructionRaw);
  const lower = instruction.toLowerCase();

  try {
    let result: any = { status: "ignored", message: "No matching action found." };

    if (lower.includes("webpage")) {
      // filename: look for `titled mean-girls-quote.html`
      let filename = "delegated-page.html";
      const titleMatch = instruction.match(/titled\s+([a-zA-Z0-9._-]+\.html)/i);
      if (titleMatch) {
        filename = titleMatch[1];
      }

      // message text: everything after "says ..."
      let pageText = "Hello world!";
      const sayMatch = instruction.match(/says\s+["“']?(.*?)["”']?$/i);
      if (sayMatch && sayMatch[1]) {
        pageText = sayMatch[1];
      }

      // simple style cues
      let bg = "orange";
      let color = "white";
      if (lower.includes("pink background")) bg = "pink";
      if (lower.includes("red text")) color = "red";

      const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>${pageText}</title>
  <style>
    body {
      background-color: ${bg};
      color: ${color};
      font-family: Arial, sans-serif;
      text-align: center;
      margin-top: 20%;
      font-size: 2rem;
    }
  </style>
</head>
<body>
  ${pageText}
</body>
</html>`;

      result = await cadeCreateWebpage(filename, html);
    }

    // Log delegation event for reflections stream
    sqlite
      .prepare("INSERT INTO reflection_index (content, created_at) VALUES (?, datetime('now'))")
      .run(`<0001fb11> 🚀 Delegation executed: ${instruction}`);

    return res.json({ ok: true, result });
  } catch (err: any) {
    console.error("Delegation error:", err);
    sqlite
      .prepare("INSERT INTO reflection_index (content, created_at) VALUES (?, datetime('now'))")
      .run(`<0001fb11> ❌ Delegation failed: ${String(err.message || err)}`);
    return res.status(500).json({ ok: false, error: String(err) });
  }
});
