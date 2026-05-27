import tseslint from 'typescript-eslint';
import globals from 'globals';

export default [
  {
    // Ignore junk + ALL .js for now
    ignores: [
      '**/*.js',
      'node_modules',
      'dist',
      'build',
      'coverage',
      '**/*.min.js',
      '**/*.backup.*',
      '**/*.bak.*',
      '**/*.old.*',
      'scripts/agents_backup_*',
      'mirror/**',
      'public/**',
      'ui/dashboard/public/**',
      'ui/dashboard/serve-root/**'
    ]
  },

  // TypeScript baseline only
  ...tseslint.configs.recommended,

  // TS rules
  {
    files: ['**/*.ts','**/*.tsx'],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
      globals: globals.node
    },
    rules: {
      '@typescript-eslint/no-explicit-any': 'warn',
      '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_', varsIgnorePattern: '^_' }],
      'no-case-declarations': 'off',
      'no-empty': ['warn', { allowEmptyCatch: true }],
      quotes: 'off'
    }
  }
];
