
/**

 * Phase 726 semantic artifact classifier.

 *

 * Additive helper only.

 * Not wired into runtime execution yet.

 * Does not mutate task, retry, SSE, route, database, or artifact persistence contracts.

 */

function normalizeText(input) {

  return String(input || '').trim();

}

function includesAny(text, terms) {

  const lower = text.toLowerCase();

  return terms.some((term) => lower.includes(term));

}

function classifyArtifact(input) {

  const text = normalizeText(input);

  const visualArtifact = includesAny(text, [

    'visual',

    'card',

    'launch card',

    'poster',

    'flyer',

    'graphic',

    'design',

    'preview',

    'dashboard',

    'briefing visual'

  ]);

  let artifactKind = 'markdown';

  if (visualArtifact && includesAny(text, ['launch card', 'card'])) {

    artifactKind = 'launch_card';

  } else if (visualArtifact && includesAny(text, ['dashboard'])) {

    artifactKind = 'visual';

  } else if (visualArtifact) {

    artifactKind = 'visual';

  } else if (includesAny(text, ['report', 'summary report'])) {

    artifactKind = 'report';

  } else if (includesAny(text, ['plan', 'roadmap', 'strategy'])) {

    artifactKind = 'plan';

  } else if (includesAny(text, ['checklist', 'steps', 'to-do', 'todo'])) {

    artifactKind = 'checklist';

  }

  let semanticIntent = 'inform';

  if (visualArtifact) {

    semanticIntent = 'visualize';

  } else if (includesAny(text, ['summarize', 'summary', 'recap'])) {

    semanticIntent = 'summarize';

  } else if (includesAny(text, ['plan', 'roadmap', 'strategy'])) {

    semanticIntent = 'plan';

  } else if (includesAny(text, ['compare', 'versus', 'vs.'])) {

    semanticIntent = 'compare';

  } else if (includesAny(text, ['execute', 'run', 'deploy', 'build'])) {

    semanticIntent = 'execute';

  }

  return {

    schema_version: 'semantic-artifact.v1',

    artifact_kind: artifactKind,

    semantic_intent: semanticIntent,

    visual_artifact: visualArtifact,

    fallback_markdown: text

  };

}

module.exports = {

  classifyArtifact

};

