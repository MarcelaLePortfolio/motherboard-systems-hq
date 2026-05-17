
/**

 * Phase 728 artifact semantic metadata adapter.

 *

 * Additive runtime-attached helper.

 * Prepares optional semantic metadata beside an existing artifact object.

 *

 * Boundary:

 * - artifact-scoped metadata only

 * - observational semantics only

 * - renderer-independent

 * - non-authoritative

 * - no task, retry, SSE, route, database, or persistence contract mutation

 */

const { composeSemanticArtifact } = require('./composeSemanticArtifact');

const { validateSemanticArtifact } = require('./validateSemanticArtifact');

function prepareArtifactSemanticMetadata(input) {

  try {

    const source = String(input || '').trim();

    if (!source) {

      return null;

    }

    const payload = composeSemanticArtifact(source);

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

