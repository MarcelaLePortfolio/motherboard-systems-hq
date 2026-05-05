export async function handleChat(req, res) {
  if (req.method !== 'POST') {
    res.writeHead(405, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ error: 'Method not allowed' }));
  }

  let body = '';
  req.on('data', chunk => {
    body += chunk;
  });

  req.on('end', () => {
    let input = '';
    try {
      const parsed = JSON.parse(body);
      input = parsed.input || '';
    } catch {
      input = '';
    }

    const response = {
      reply: `Advisory response only: received input "${input}". No execution performed.`,
      meta: {
        mode: 'advisory-deterministic',
        execution: false,
        systemCoupling: false
      }
    };

    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(response));
  });
}
