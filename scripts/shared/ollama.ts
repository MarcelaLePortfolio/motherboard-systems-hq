import { spawn } from "child_process";

export async function runOllamaPrompt(prompt: string, model = "mistral") {
  return new Promise((resolve, reject) => {
    let output = "";

    const ollama = spawn("ollama", ["run", model], { stdio: ["pipe", "pipe", "inherit"] });

    ollama.stdout.on("data", (data) => {
      output += data.toString();
    });

    ollama.on("close", (code) => {
      if (code === 0) {
        resolve(output.trim());
      } else {
        reject(new Error(`Ollama exited with code ${code}`));
      }
    });

    ollama.stdin.write(prompt);
    ollama.stdin.end();
  });
}
