
function includesAny(text, patterns) {

  return patterns.some(pattern => pattern.test(text));

}

function buildAdvisoryReply(normalized) {

  const lower = normalized.toLowerCase();

  const executionRequest = includesAny(normalized, [

    /\bexecute\b/i,

    /\brun task\b/i,

    /\bdeploy\b/i,

    /\brestart\b/i,

    /\bshutdown\b/i,

    /\bdelete\b/i,

    /\bmodify database\b/i,

    /\btrigger worker\b/i,

    /\bpush\b/i,

    /\bcommit\b/i

  ]);

  if (!normalized) {

    return 'I can provide advisory guidance, summarize visible system state, explain runtime behavior, and help reason through next steps. I cannot execute tasks, modify infrastructure, mutate data, or trigger workers from this chat surface.';

  }

  if (executionRequest) {

    return [

      'I cannot execute that from this advisory chat surface.',

      'Execution pathways remain isolated from chat, and no task, worker, database, deployment, or infrastructure action has been triggered.',

      'I can still help you reason through the safest next command, validation step, rollback point, or operator decision.'

    ].join(' ');

  }

  if (includesAny(normalized, [/who are you/i, /what are you/i, /\bpurpose\b/i])) {

    return 'I am Matilda, an advisory-only system interface for the Motherboard Systems dashboard. My role is to interpret visible runtime context, explain boundaries, support operator reasoning, and help plan safe next steps without performing execution.';

  }

  if (includesAny(normalized, [/\bstatus\b/i, /\bstate\b/i, /\bhealthy\b/i, /\bcheck\b/i, /\binspector\b/i])) {

    return [

      'For a status-oriented question, I can separate what is known from what needs verification.',

      'Known: this chat surface is advisory-only and does not mutate runtime state.',

      'Next useful check: compare the visible dashboard state, Execution Inspector stream, and recent task events before concluding that anything changed.',

      'If the inspector is idle, that can be healthy when no task event is currently flowing.'

    ].join(' ');

  }

  if (includesAny(normalized, [/\bdebug\b/i, /\berror\b/i, /\bfailing\b/i, /\bbroken\b/i, /\bfix\b/i, /\brepair\b/i])) {

    return [

      'For debugging, the safest path is to isolate one hypothesis and validate it before patching.',

      'Start by identifying the exact failing surface, the last known stable checkpoint, and the smallest command that proves or disproves the suspected cause.',

      'Avoid layering fixes until the current error clearly points to the next step.'

    ].join(' ');

  }

  if (includesAny(normalized, [/\bplan\b/i, /\bnext step\b/i, /\bprioritize\b/i, /\bcorridor\b/i, /\broadmap\b/i])) {

    return [

      'The safest next-step structure is: preserve the stable checkpoint, choose one narrow refinement target, define the validation proof, then patch only that target.',

      'For advisory cognition work, prioritize reasoning quality before expanding context.',

      'That keeps usefulness improving without increasing the hallucination surface too early.'

    ].join(' ');

  }

  if (includesAny(normalized, [/\barchitecture\b/i, /\bdesign\b/i, /\bsystem\b/i, /\bboundary\b/i, /\bisolation\b/i])) {

    return [

      'Architecturally, the key boundary is that chat may interpret and advise, but it must not execute, mutate, or silently couple to workers.',

      'A safe design keeps runtime context read-only, labels uncertainty explicitly, and routes actual execution through separate verified pathways.',

      'That preserves operator trust while still allowing strategic reasoning.'

    ].join(' ');

  }

  if (includesAny(normalized, [/\bconfused\b/i, /\bunsure\b/i, /\bnot sure\b/i, /\bwhat does\b/i, /\bexplain\b/i])) {

    return [

      'I can help clarify by separating the issue into known facts, likely interpretation, and what still needs verification.',

      'The important rule is not to treat absence of evidence as proof of failure.',

      'A good next move is to identify which visible signal would confirm the interpretation.'

    ].join(' ');

  }

  return [

    'Advisory guidance only: I can help reason through this without executing anything.',

    'A safe way to proceed is to identify the goal, the known runtime facts, the uncertain assumptions, and the smallest validation step.',

    'No execution has been performed from this chat surface.'

  ].join(' ');

}

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

    const reply = buildAdvisoryReply(normalized);

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

