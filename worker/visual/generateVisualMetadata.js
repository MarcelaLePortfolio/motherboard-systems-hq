
/**

 * Phase 726 visual metadata helper.

 *

 * Additive helper only.

 * Not connected to runtime execution.

 * No contract mutation permitted.

 */

function normalizeText(input) {

  return String(input || '').trim();

}

function includesAny(text, terms) {

  const lower = text.toLowerCase();

  return terms.some((term) => lower.includes(term));

}

function inferLayout(text) {

  if (includesAny(text, ['dashboard'])) {

    return 'dashboard';

  }

  if (includesAny(text, ['poster', 'flyer'])) {

    return 'poster';

  }

  if (includesAny(text, ['brief'])) {

    return 'brief';

  }

  return 'card';

}

function inferTone(text) {

  if (includesAny(text, ['luxury', 'premium', 'elegant'])) {

    return 'elevated';

  }

  if (includesAny(text, ['playful', 'fun', 'kids'])) {

    return 'playful';

  }

  if (includesAny(text, ['corporate', 'executive'])) {

    return 'executive';

  }

  return 'standard';

}

function inferAudience(text) {

  if (includesAny(text, ['investor', 'stakeholder'])) {

    return 'stakeholders';

  }

  if (includesAny(text, ['customer', 'client'])) {

    return 'customers';

  }

  if (includesAny(text, ['internal', 'team'])) {

    return 'internal';

  }

  return 'general';

}

function generateVisualMetadata(input) {

  const text = normalizeText(input);

  return {

    layout: inferLayout(text),

    tone: inferTone(text),

    audience: inferAudience(text),

    render_hint: 'phase726_additive_visual_metadata_only'

  };

}

module.exports = {

  generateVisualMetadata

};

