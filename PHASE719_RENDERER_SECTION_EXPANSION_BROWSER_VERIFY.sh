
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 RENDERER SECTION EXPANSION BROWSER VERIFY ====="

rm -rf /tmp/phase719_renderer_section_verify

mkdir -p /tmp/phase719_renderer_section_verify

cd /tmp/phase719_renderer_section_verify

npm init -y >/dev/null 2>&1

npm install playwright@latest >/tmp/phase719_renderer_section_verify_install.log 2>&1

cat > probe.mjs << 'NODE'

import { chromium } from "playwright";

import fs from "fs";

const browser = await chromium.launch({ headless: true });

const page = await browser.newPage({ viewport: { width: 1440, height: 1000 } });

await page.goto("http://localhost:3000?v=" + Date.now(), { waitUntil: "domcontentloaded" });

await page.waitForTimeout(1500);

const buttons = page.locator("[data-phase719-preview-artifact]");

const count = await buttons.count();

console.log("previewButtonCount:", count);

if (!count) {

  console.log("No preview buttons found.");

  await browser.close();

  process.exit(0);

}

await buttons.first().click();

await page.waitForTimeout(1800);

const result = await page.evaluate(() => {

  const modal = document.querySelector("#phase719-preview-modal");

  const iframe = modal?.querySelector("iframe");

  const srcdoc = iframe?.getAttribute("srcdoc") || "";

  return {

    modalDisplay: modal ? getComputedStyle(modal).display : null,

    iframeExists: !!iframe,

    srcdocLength: srcdoc.length,

    hasSummary: srcdoc.includes(">Summary<") || srcdoc.includes("Summary"),

    hasDeliverable: srcdoc.includes(">Deliverable<") || srcdoc.includes("Deliverable"),

    hasDetails: srcdoc.includes(">Details<") || srcdoc.includes("Details"),

    hasRecommendations: srcdoc.includes(">Recommendations<") || srcdoc.includes("Recommendations"),

    hasNextSteps: srcdoc.includes(">Next Steps<") || srcdoc.includes("Next Steps"),

    hasOutcome: srcdoc.includes(">Outcome<") || srcdoc.includes("Outcome"),

    srcdocPreview: srcdoc.slice(0, 2500)

  };

});

fs.writeFileSync("/tmp/phase719_renderer_section_srcdoc.html", result.srcdocPreview);

console.log(JSON.stringify(result, null, 2));

await page.screenshot({ path: "/tmp/phase719_renderer_section_verify.png", fullPage: true });

console.log("screenshotSaved:/tmp/phase719_renderer_section_verify.png");

await browser.close();

NODE

node probe.mjs

echo "===== PHASE 719 RENDERER SECTION EXPANSION BROWSER VERIFY COMPLETE ====="

