
import fs from "fs";

import { execSync } from "child_process";

const routes = execSync('find routes -type f -name "*.ts"')

  .toString()

  .trim()

  .split('\n')

  .filter(Boolean);

const report = {

  missingRouter: [],

  hasRouter: [],

  duplicateExpress: [],

  dbLegacy: []

};

for (const file of routes) {

  const content = fs.readFileSync(file, "utf8");

  if (!content.includes("express.Router")) {

    report.missingRouter.push(file);

  } else {

    report.hasRouter.push(file);

  }

  if ((content.match(/import express/g) || []).length > 1) {

    report.duplicateExpress.push(file);

  }

  if (content.includes("sqlite.prepare")) {

    report.dbLegacy.push(file);

  }

}

console.log(JSON.stringify(report, null, 2));

