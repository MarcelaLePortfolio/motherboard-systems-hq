document.addEventListener('DOMContentLoaded', () => {
  const inputEl = document.getElementById('command-input');
  const opsStream = document.getElementById('ops-stream');

  function appendToOpsStream(message) {
    const entry = document.createElement('div');
    entry.textContent = message;
    opsStream.appendChild(entry);
    opsStream.scrollTop = opsStream.scrollHeight;
  }

  inputEl.addEventListener('keydown', async (e) => {
    if (e.key === 'Enter') {
      e.preventDefault();
      const input = inputEl.value.trim();
      if (!input) return;

      appendToOpsStream(`🟣 You: ${input}`);
      inputEl.value = '';

      const res = await fetch('/api/matilda', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ input }),
      });

      const data = await res.json();
      appendToOpsStream(`🟢 Matilda: ${data.message}`);
    }
  });
});
