#!/usr/bin/env tsx
import { ask } from "../agents/matilda/askRouter.ts";

const input = process.argv.slice(2).join(" ").trim();
if (!input) {
  console.error("Please provide a command or question for Matilda.");
  process.exit(1);
}

ask(input)
  .then((response) => console.log(`Matilda: ${response}`))
  .catch((err) => console.error("Matilda encountered an error:", err));
