
/**

 * Phase 726 semantic artifact composer.

 *

 * Additive inspect-only helper.

 * Combines semantic classification with optional visual composition metadata.

 * Not wired into runtime execution.

 */

const { classifyArtifact } = require('./classifyArtifact');

const { generateVisualMetadata } = require('../visual/generateVisualMetadata');

function composeSemanticArtifact(input) {

  const base = classifyArtifact(input);

  if (!base.visual_artifact) {

    return base;

  }

  return {

    ...base,

    visual_composition: generateVisualMetadata(input)

  };

}

module.exports = {

  composeSemanticArtifact

};

