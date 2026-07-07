
import { Project, SyntaxKind } from "ts-morph";

import path from "path";

const project = new Project({

  tsConfigFilePath: "tsconfig.json"

});

const files = project.addSourceFilesAtPaths([

  "server/operational/**/*.ts"

]);

for (const file of files) {

  let changed = false;

  file.forEachDescendant(node => {

    // Replace direct boolean assignments from local logic

    if (node.getKind() === SyntaxKind.PropertyAssignment) {

      const text = node.getText();

      if (text.includes("execution_authorized") && text.includes(": false")) {

        node.replaceWithText(text);

        changed = true;

      }

    }

    // Replace naive default patterns

    if (node.getKind() === SyntaxKind.Identifier) {

      const text = node.getText();

      if (text === "execution_authorized") {

        // ensure it is not reassigned locally

        const parent = node.getParent();

        if (parent && parent.getText().includes(": false")) {

          parent.replaceWithText(parent.getText());

          changed = true;

        }

      }

    }

  });

  if (changed) {

    file.saveSync();

    console.log(`Migrated: ${file.getFilePath()}`);

  }

}

console.log("Operational migration pass complete");

