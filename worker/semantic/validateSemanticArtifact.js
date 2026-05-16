
/**

 * Phase 726 semantic artifact contract validator.

 *

 * Inspect-only validation helper.

 * Does not require external dependencies.

 * Does not wire schema output into runtime execution.

 */

const fs = require('fs');

const path = require('path');

const schemaPath = path.resolve(__dirname, '../../contracts/artifacts/semantic-artifact-schema.v1.json');

const schema = JSON.parse(fs.readFileSync(schemaPath, 'utf8'));

function fail(message) {

  return {

    valid: false,

    errors: [message]

  };

}

function validateEnum(value, allowed, field) {

  if (!allowed.includes(value)) {

    return `${field} must be one of: ${allowed.join(', ')}`;

  }

  return null;

}

function validateSemanticArtifact(payload) {

  if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {

    return fail('payload must be an object');

  }

  const errors = [];

  for (const requiredField of schema.required) {

    if (!(requiredField in payload)) {

      errors.push(`${requiredField} is required`);

    }

  }

  if (payload.schema_version !== 'semantic-artifact.v1') {

    errors.push('schema_version must be semantic-artifact.v1');

  }

  const artifactKindError = validateEnum(

    payload.artifact_kind,

    schema.properties.artifact_kind.enum,

    'artifact_kind'

  );

  if (artifactKindError) {

    errors.push(artifactKindError);

  }

  const semanticIntentError = validateEnum(

    payload.semantic_intent,

    schema.properties.semantic_intent.enum,

    'semantic_intent'

  );

  if (semanticIntentError) {

    errors.push(semanticIntentError);

  }

  if (typeof payload.fallback_markdown !== 'string') {

    errors.push('fallback_markdown must be a string');

  }

  if ('visual_artifact' in payload && typeof payload.visual_artifact !== 'boolean') {

    errors.push('visual_artifact must be a boolean when present');

  }

  if ('sections' in payload && !Array.isArray(payload.sections)) {

    errors.push('sections must be an array when present');

  }

  if ('visual_composition' in payload) {

    const composition = payload.visual_composition;

    if (!composition || typeof composition !== 'object' || Array.isArray(composition)) {

      errors.push('visual_composition must be an object when present');

    } else if (

      'layout' in composition &&

      !schema.properties.visual_composition.properties.layout.enum.includes(composition.layout)

    ) {

      errors.push('visual_composition.layout is not allowed');

    }

  }

  return {

    valid: errors.length === 0,

    errors

  };

}

module.exports = {

  validateSemanticArtifact

};

