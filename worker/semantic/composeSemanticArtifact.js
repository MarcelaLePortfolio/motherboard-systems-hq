
/**

 * Phase 728 semantic artifact composer.

 *

 * Additive runtime-attached helper.

 * Combines semantic classification with optional visual composition metadata.

 *

 * Boundary:

 * - artifact-scoped metadata only

 * - observational semantics only

 * - renderer-independent

 * - non-authoritative

 * - no task, retry, SSE, route, database, preview, or persistence contract mutation

 */

const { classifyArtifact } = require('./classifyArtifact');

const { extractSections } = require('./extractSections');

const { generateVisualMetadata } = require('../visual/generateVisualMetadata');

function composeSemanticArtifact(input) {

  const base = classifyArtifact(input);

  const sections = extractSections(input);

  const semanticBase = sections.length > 0 ? { ...base, sections } : base;

  if (!semanticBase.visual_artifact) {

    return semanticBase;

  }

  return {

    ...semanticBase,

    visual_composition: generateVisualMetadata(input)

  };

}

module.exports = {

  composeSemanticArtifact

};

