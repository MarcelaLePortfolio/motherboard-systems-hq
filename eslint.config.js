import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import globals from 'globals';

export default [
  // Ignore junk
  {
    ignores: [
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

  // Baseline
  js.configs.recommended,
  ...tseslint.configs.recommended,

  // TS rules (what lint-staged is running)
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
