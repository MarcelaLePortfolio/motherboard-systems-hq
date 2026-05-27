/* eslint-disable import/no-commonjs */
import { generateMarkdownFile } from "../tools/generateMarkdownFile.mjs";

export function handleGenerateFile(summary) {
  let filename = "output.md";
  let content = "# Placeholder Content";

  if (/welcome kit/i.test(summary)) {
    filename = "welcome_kit.md";
    content = `# 🤖 Welcome Kit for New Agents

Welcome aboard! This markdown file is your official onboarding guide.

## What's Inside

- Overview of your responsibilities
- How to interact with other agents
- System expectations
- Safety & autonomy guidelines

## Agent Roles

| Agent   | Function             |
|---------|----------------------|
| Matilda | Delegation & liaison |
| Cade    | Backend automator    |
| Effie   | Local ops assistant  |

Enjoy your mission! 🚀`;
  }

  generateMarkdownFile(filename, content);
}
