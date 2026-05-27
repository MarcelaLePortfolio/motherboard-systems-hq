module.exports = {
  ignorePatterns: [
    "**/*.bak.*",
    "**/*.old.*",
    "scripts/**/*_patch.js",
    "scripts/**/*_stub.*",
    "scripts/**/*_backup_*",
    "scripts/**/*_clean.*",
    "scripts/**/*rogue*",
    "scripts/**/*auto-deploy*",
    "scripts/**/*runtime_simulation*",
  ],
  parser: "@typescript-eslint/parser",
  plugins: ["@typescript-eslint"],
  extends: [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  parserOptions: {
    ecmaVersion: "latest",
    sourceType: "module",
  },
  env: {
    node: true,
    browser: true,
    es2022: true,
  },
  rules: {
    // add custom rules here if needed
  },
};
