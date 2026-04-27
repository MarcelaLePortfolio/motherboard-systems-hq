console.log('[phase62_delegation_wire] boot');

const input = document.getElementById('delegation-input');
const button = document.getElementById('delegation-submit');

if (!input || !button) {
  console.warn('[phase62] delegation elements not found');
} else {
  button.addEventListener('click', async () => {
    const text = input.value.trim();

    if (!text) {
      console.warn('[phase62] empty input');
      return;
    }

    console.log('[phase62] submitting task:', text);

    try {
      const res = await fetch('/api/delegate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title: text }),
      });

      const data = await res.json();

      console.log('[phase62] response:', data);

      input.value = '';
    } catch (err) {
      console.error('[phase62] submission failed:', err);
    }
  });
}
