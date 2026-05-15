
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 ARTIFACT HTML CONTENT INSPECTION ====="

rm -rf /tmp/phase719_artifact_html_probe

mkdir -p /tmp/phase719_artifact_html_probe

cd /tmp/phase719_artifact_html_probe

npm init -y >/dev/null 2>&1

npm install playwright@latest >/tmp/phase719_artifact_html_probe_install.log 2>&1

cat > probe.mjs << 'NODE'

import { chromium } from "playwright";

import fs from "fs";

const browser = await chromium.launch({ headless: true });

const page = await browser.newPage({ viewport: { width: 1440, height: 1000 } });

await page.goto("http://localhost:3000", { waitUntil: "domcontentloaded" });

await page.waitForTimeout(1200);

const previewCount = await page.locator("[data-phase719-preview-artifact]").count();

console.log("previewButtonCount:", previewCount);

if (!previewCount) {

  console.log("No Preview buttons found.");

  await browser.close();

  process.exit(0);

}

await page.locator("[data-phase719-preview-artifact]").first().click();

await page.waitForTimeout(1800);

const result = await page.evaluate(() => {

  const modal = document.querySelector("#phase719-preview-modal");

  const iframe = modal?.querySelector("iframe");

  const srcdoc = iframe?.getAttribute("srcdoc") || "";

  const modalRect = modal?.getBoundingClientRect();

  const iframeRect = iframe?.getBoundingClientRect();

  return {

    modalDisplay: modal ? getComputedStyle(modal).display : null,

    modalRect: modalRect ? {

      width: Math.round(modalRect.width),

      height: Math.round(modalRect.height)

    } : null,

    iframeRect: iframeRect ? {

      width: Math.round(iframeRect.width),

      height: Math.round(iframeRect.height)

    } : null,

    srcdocLength: srcdoc.length,

    hasRenderedArtifactRoot: srcdoc.includes("data-phase719-rendered-artifact-preview"),

    hasOutcome: srcdoc.includes("Outcome"),

    hasBuildPath: srcdoc.includes("Build Path"),

    srcdoc

  };

});

fs.writeFileSync("/tmp/phase719_artifact_srcdoc.html", result.srcdoc);

delete result.srcdoc;

console.log(JSON.stringify(result, null, 2));

console.log("srcdocSaved:/tmp/phase719_artifact_srcdoc.html");

await page.screenshot({ path: "/tmp/phase719_artifact_preview_page.png", fullPage: true });

console.log("screenshotSaved:/tmp/phase719_artifact_preview_page.png");

await browser.close();

NODE

node probe.mjs

echo ""

echo "===== SAVED SRCDOC HEAD ====="

sed -n '1,80p' /tmp/phase719_artifact_srcdoc.html

echo ""

echo "===== PHASE 719 ARTIFACT HTML CONTENT INSPECTION COMPLETE ====="

