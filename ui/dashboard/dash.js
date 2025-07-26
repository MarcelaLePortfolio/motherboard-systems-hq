// dash.js – includes basic command submission wiring

document.addEventListener("DOMContentLoaded", () => {
  const input = document.getElementById("commandInput");

  input.addEventListener("keydown", async (event) => {
    if (event.key === "Enter") {
      const value = input.value.trim();

      // Simple command detection: must start with known patterns
      const isCommand = /^(matilda:|cade:|effie:|run |cd |open |\/|\>)/i.test(value);

      if (isCommand) {
        await submitCommand(value);
        input.value = "";
      }
    }
  });
});

async function submitCommand(command) {
  try {
    const res = await fetch("/api/command", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ command }),
    });

    if (!res.ok) {
      console.error("Command failed:", await res.text());
    } else {
      console.log("Command submitted:", command);
    }
  } catch (err) {
    console.error("Command error:", err);
  }
}
