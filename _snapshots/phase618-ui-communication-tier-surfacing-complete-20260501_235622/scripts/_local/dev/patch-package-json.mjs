import fs from 'node:fs';

const pkgPath = new URL('../../../../package.json', import.meta.url).pathname;

if (!fs.existsSync(pkgPath)) {
console.error('❌ package.json not found at project root');
process.exit(1);
}

const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
pkg.scripts ||= {};

// Force the build script to our skip wrapper
pkg.scripts.build = 'node scripts/_local/dev/skip-ui-build.js';

// Ensure a default UI build exists (only runs when ENABLE_UI_BUILD=1)
if (!pkg.scripts['build:ui']) {
// You can later change this to your actual UI build (e.g. turbo build, vite build)
pkg.scripts['build:ui'] = 'next build';
}

// Proactively remove any capacitor-specific scripts (we're not app-wrapping in M2)
for (const key of Object.keys(pkg.scripts)) {
const val = String(pkg.scripts[key] ?? '');
if (/capacitor|cap\s/i.test(key) || /capacitor|@capacitor/i.test(val)) {
delete pkg.scripts[key];
}
}

// Write back with stable formatting
fs.writeFileSync(pkgPath, JSON.stringify(pkg, null, 2) + '\n', 'utf8');
console.log('✅ Patched package.json:');
console.log(' - scripts.build -> node scripts/_local/dev/skip-ui-build.js');
console.log(' - scripts.build:ui (default) -> next build');
console.log(' - removed capacitor-related scripts (if any)');
