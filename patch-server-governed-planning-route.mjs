
import fs from "fs";

const file = "server.mjs";

let src = fs.readFileSync(file, "utf8");

const importLine =

  'import governedPlanningRouter from "./server/routes/governed-planning-route.mjs";';

const importAnchor =

  'import apiTasksMutationsRouter from "./server/routes/api-tasks-mutations.mjs";';

const mountLine =

  'app.use(governedPlanningRouter);';

const mountAnchor =

  'app.use("/api/tasks-mutations", apiTasksMutationsRouter);';

if (!src.includes(importLine)) {

  if (!src.includes(importAnchor)) {

    throw new Error("governed planning import anchor not found");

  }

  src = src.replace(importAnchor, `${importAnchor}\n${importLine}`);

}

if (!src.includes(mountLine)) {

  if (!src.includes(mountAnchor)) {

    throw new Error("governed planning mount anchor not found");

  }

  src = src.replace(mountAnchor, `${mountAnchor}\n${mountLine}`);

}

fs.writeFileSync(file, src);

console.log("Mounted governed planning route in server.mjs");

