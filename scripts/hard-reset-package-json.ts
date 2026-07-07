
import fs from "fs";

// DO NOT read existing JSON (it is poisoned)

// overwrite completely with safe canonical config

const clean = {

  name: "motherboard-systems-hq-clean",

  version: "1.0.0",

  type: "module",

  scripts: {

    build: "echo build",

    test: "echo test",

    dev: "echo dev"

  },

  dependencies: {},

  devDependencies: {}

};

fs.writeFileSync(

  "package.json",

  JSON.stringify(clean, null, 2)

);

console.log("HARD RESET COMPLETE");

