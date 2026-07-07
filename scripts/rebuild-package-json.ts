
import fs from "fs";

const raw = fs.readFileSync("package.json", "utf8");

// extract only valid JSON portion by brute recovery

const match = raw.slice(raw.indexOf("{"), raw.lastIndexOf("}") + 1);

let data;

try {

  data = JSON.parse(match);

} catch (e) {

  console.error("JSON still corrupted — forcing minimal recovery");

  data = {

    name: "motherboard-systems-hq-clean",

    version: "1.0.0",

    type: "module",

    scripts: {},

    dependencies: {},

    devDependencies: {}

  };

}

// ensure required fields exist

data.type = "module";

data.scripts = data.scripts || {};

data.dependencies = data.dependencies || {};

data.devDependencies = data.devDependencies || {};

fs.writeFileSync("package.json", JSON.stringify(data, null, 2));

console.log("package.json rebuilt safely");

