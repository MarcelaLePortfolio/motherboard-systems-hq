/**

Milestone 2 focus: completely skip UI/app builds (including Capacitor) unless explicitly enabled.

Enable with: ENABLE_UI_BUILD=1 pnpm run build
*/
const { spawnSync } = require('node:child_process');

if (process.env.ENABLE_UI_BUILD === '1') {
console.log('🔧 ENABLE_UI_BUILD=1 — running real UI build (pnpm run build:ui)');
const res = spawnSync('pnpm', ['run', 'build:ui'], { stdio: 'inherit', shell: true });
process.exit(res.status ?? 1);
} else {
console.log('⏭️ Skipping UI/app build for Milestone 2 reliability work. Set ENABLE_UI_BUILD=1 to enable.');
process.exit(0);
}
