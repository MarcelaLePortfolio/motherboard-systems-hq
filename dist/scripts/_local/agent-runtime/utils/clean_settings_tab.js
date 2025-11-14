export function cleanSettings(html) {
    // TODO: Strip rogue post-html content
    return html.replace(/<\/html>[\s\S]*$/, '</html>');
}
