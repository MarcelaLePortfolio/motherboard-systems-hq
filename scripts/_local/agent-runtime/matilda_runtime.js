#!/usr/bin/env node
import readline from "readline";
import fetch from "node-fetch";
import { logTickerEvent } from "./utils/logTickerEvent.js";

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  prompt: "Matilda> ",
});

let awaitingConfirmation = null;

// --- Detect agent name from delegation intent ---
function detectDelegationIntent(text) {
  const lower = text.toLowerCase();
  if (lower.includes("delegate to cade")) return "Cade";
  if (lower.includes("delegate to effie")) return "Effie";
  return null;
}

async function processInput(input) {
  const trimmed = input.trim();
  const lower = trimmed.toLowerCase();

  // Handle confirmation of delegation
  if (awaitingConfirmation) {
    if (["yes", "y"].includes(lower)) {
      const { agent, text } = awaitingConfirmation;
      console.log(`Matilda: ✅ ${agent} acknowledged — working on it now.`);
      logTickerEvent("matilda", `delegated-to-${agent.toLowerCase()}`);
      logTickerEvent(agent.toLowerCase(), `command-received: ${text}`);
      logTickerEvent(agent.toLowerCase(), `task-complete`);
      awaitingConfirmation = null;
    } else if (["no", "n", "cancel"].includes(lower)) {
      console.log("Matilda: Delegation canceled.");
      awaitingConfirmation = null;
    } else {
      console.log("Matilda: Please confirm with yes or no.");
    }
    return rl.prompt();
  }

  // Detect new delegation
  const agent = detectDelegationIntent(trimmed);
  if (agent) {
    awaitingConfirmation = { agent, text: trimmed };
    console.log(`🤔 Matilda: Should I delegate this to ${agent}? (yes/no)`);
    return rl.prompt();
  }

  // Default: Chat via Ollama
  try {
    const response = await fetch("http://127.0.0.1:11434/api/generate", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ model: "llama3:8b", prompt: trimmed, stream: false }),
    });
    const data = await response.json();
    console.log(`💬 Matilda: ${data.response || "(no response)"}`);
  } catch (err) {
    console.error("❌ Error communicating with Ollama:", err.message);
  }

  rl.prompt();
}

// --- Startup ---
console.log("💚 Matilda Runtime Started — Filtered Liaison Mode (Friendly Only)");
logTickerEvent("matilda", "agent-online");

rl.prompt();
rl.on("line", processInput);
