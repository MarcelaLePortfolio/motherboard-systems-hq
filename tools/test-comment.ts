import { cadeCommandRouter } from '../scripts/agents/cade';

cadeCommandRouter('comment', {
  file: 'scripts/agents/cade.ts',
  outputPath: 'commented/cade-commented.ts'
}).then(res => {
  console.log('✅ Commented file saved to:', res.commentedPath);
}).catch(err => {
  console.error('❌ Error:', err.message);
});
