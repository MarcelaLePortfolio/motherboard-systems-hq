
/**

 * Phase 730 semantic section extractor.

 *

 * Additive helper only.

 * Produces optional artifact-scoped sections for observability.

 *

 * Boundary:

 * - markdown/text parsing only

 * - observational semantics only

 * - renderer-independent

 * - non-authoritative

 * - no task, retry, SSE, route, database, preview, or persistence contract mutation

 */

function normalizeText(input) {

  return String(input || '').trim();

}

function cleanLabel(input) {

  return String(input || '')

    .replace(/^#{1,6}\s*/, '')

    .replace(/[:：]\s*$/, '')

    .trim();

}

function extractSections(input) {

  const text = normalizeText(input);

  if (!text) {

    return [];

  }

  const lines = text.split(/\r?\n/);

  const sections = [];

  let current = null;

  for (const line of lines) {

    const headingMatch = line.match(/^\s{0,3}#{1,6}\s+(.+?)\s*$/);

    const labelMatch = line.match(/^\s{0,3}([A-Z][A-Za-z0-9 /&()-]{2,60})[:：]\s*$/);

    if (headingMatch || labelMatch) {

      if (current && current.content.trim()) {

        sections.push({

          label: current.label,

          content: current.content.trim(),

          priority: sections.length

        });

      }

      current = {

        label: cleanLabel((headingMatch || labelMatch)[1]),

        content: ''

      };

      continue;

    }

    if (current) {

      current.content += `${line}\n`;

    }

  }

  if (current && current.content.trim()) {

    sections.push({

      label: current.label,

      content: current.content.trim(),

      priority: sections.length

    });

  }

  return sections;

}

module.exports = {

  extractSections

};

