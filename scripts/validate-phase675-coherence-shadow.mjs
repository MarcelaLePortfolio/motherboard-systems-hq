const base = process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:8080';

async function main() {
  let res;

  try {
    res = await fetch(`${base}/api/guidance/coherence-shadow`, { cache: 'no-store' });
  } catch (err) {
    console.error('Phase 675 coherence shadow validation pending');
    console.error(`Unable to reach ${base}/api/guidance/coherence-shadow`);
    console.error('Start the local app/container, then rerun this script.');
    process.exit(2);
  }

  if (!res.ok) {
    throw new Error(`Shadow endpoint failed with status ${res.status}`);
  }

  const data = await res.json();

  if (data.phase !== '675') {
    throw new Error(`Expected phase 675, received ${data.phase}`);
  }

  if (data.mode !== 'coherence-shadow') {
    throw new Error(`Expected coherence-shadow mode, received ${data.mode}`);
  }

  if (!Array.isArray(data.raw)) {
    throw new Error('Expected raw to be an array');
  }

  if (!Array.isArray(data.coherent)) {
    throw new Error('Expected coherent to be an array');
  }

  if (!data.runtimeImpact || data.runtimeImpact.execution !== false || data.runtimeImpact.sse !== false || data.runtimeImpact.ui !== false || data.runtimeImpact.formatting !== false) {
    throw new Error('Runtime impact flags are not safely false');
  }

  console.log('Phase 675 coherence shadow validation passed');
  console.log(JSON.stringify({
    phase: data.phase,
    mode: data.mode,
    source: data.source,
    raw: data.raw.length,
    coherent: data.coherent.length,
  }, null, 2));
}

main();
