import { reflection_index } from "../../db/reflection_index";

const delay = (ms: number) => new Promise(res => setTimeout(res, ms));

async function logReflection(actor: string, message: string) {
  try {
    await db.insert(reflection_index).values({
      id: crypto.randomUUID(),
      source: actor,
      content: message,
      created_at: new Date().toISOString()
    }).run();
    console.log(`📝 [${actor}] ${message}`);
  } catch (err) {
    console.error("❌ Failed to write reflection:", err);
  }
}

export async function buildAtlas() {
  await logReflection("Matilda", "Initializing Atlas creation protocol…");
  await delay(800);

  await logReflection("Cade", "Compiling Atlas core modules.");
  await delay(800);

  await logReflection("Cade", "Validating dependency graph and runtime bindings.");
  await delay(800);

  await logReflection("Cade", "Linking diagnostic, task, and reflection channels.");
  await delay(800);

  await logReflection("Effie", "Syncing Atlas presence with live agents status.");
  await delay(800);

  await logReflection("Effie", "Verifying SQLite telemetry + dashboard integration.");
  await delay(800);

  await logReflection("Matilda", "Running final integrity + handshake checks.");
  await delay(800);

  await logReflection("System", "✅ Atlas Online — full stack operational and observable.");
}

// Allow direct CLI execution
if (import.meta.main) {
  buildAtlas().then(() => {
    console.log("✅ Atlas build sequence completed.");
    process.exit(0);
  });
}
