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
      input = parsed.message || parsed.input || '';
    } catch {
      input = '';
    }

    const normalized = String(input).trim();

    let reply;

    if (!normalized) {
      reply =
        'I can provide advisory guidance, summarize system state, explain visible runtime behavior, and help interpret dashboard signals. I cannot execute tasks, modify infrastructure, or trigger workers from this chat surface.';
    } else if (
      /execute|run task|deploy|restart|shutdown|delete|modify database|trigger worker/i.test(
        normalized
      )
    ) {
      reply =
        'This advisory chat surface cannot execute actions, trigger workers, modify infrastructure, or perform system mutations. Execution pathways remain isolated from chat.';
    } else if (/who are you|what are you|purpose/i.test(normalized)) {
      reply =
        'I am Matilda, an advisory-only system interface operating under a non-executing contract. My role is to help interpret runtime state, guidance signals, and operational context without performing execution.';
    } else {
      reply =
        'Advisory guidance only: I can help interpret system state, explain runtime behavior, clarify execution boundaries, and assist with operational reasoning. No execution has been performed.';
    }

    const response = {
      reply,
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
