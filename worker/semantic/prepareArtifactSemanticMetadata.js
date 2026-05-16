
/**

 * Phase 726 artifact semantic metadata adapter.

 *

 * Inactive helper.

 * Not imported by the live worker.

 * Intended future use: prepare optional semantic metadata beside an existing artifact object.

 */

const { composeSemanticArtifact } = require('./composeSemanticArtifact');

const { validateSemanticArtifact } = require('./validateSemanticArtifact');

function prepareArtifactSemanticMetadata(input) {

  try {

    const payload = composeSemanticArtifact(input);

    const validation = validateSemanticArtifact(payload);

    if (!validation.valid) {

      return null;

    }

    return {

      semantic_artifact: payload,

      semantic_artifact_validated: true,

      semantic_artifact_schema: payload.schema_version

    };

  } catch {

    return null;

  }

}

module.exports = {

  prepareArtifactSemanticMetadata

};

