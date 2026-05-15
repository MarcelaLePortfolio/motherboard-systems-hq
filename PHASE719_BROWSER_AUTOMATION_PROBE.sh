
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 BROWSER AUTOMATION PROBE ====="

echo ""

echo "[1] Runtime check"

docker compose ps

echo ""

echo "[2] Served JS style confirmation"

curl -s http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -n "phase719-preview-modal\|phase719RenderArtifactIframePreview\|srcdoc\|width:min(760px,96vw)\|height:min(820px,88vh)\|height:min(650px,70vh)" || true

echo ""

echo "[3] API artifact task confirmation"

curl -s http://localhost:3000/api/tasks | python3 -m json.tool | sed -n '1,140p'

echo ""

echo "[4] Browser automation availability check"

if command -v node >/dev/null 2>&1; then

  echo "node: $(node -v)"

else

  echo "node not found"

fi

if command -v npx >/dev/null 2>&1; then

  echo "npx: available"

else

  echo "npx not found"

fi

echo ""

echo "[5] Create temporary Playwright probe"

cat > /tmp/phase719_browser_probe.mjs << 'NODE'

import { chromium } from "playwright";

const url = "http://localhost:3000";

const browser = await chromium.launch({ headless: true });

const page = await browser.newPage({ viewport: { width: 1440, height: 1000 } });

const consoleMessages = [];

page.on("console", msg => {

  consoleMessages.push({

    type: msg.type(),

    text: msg.text(),

  });

});

await page.goto(url, { waitUntil: "networkidle" });

const previewButton = page.locator("[data-phase719-preview-artifact]").first();

const previewCount = await page.locator("[data-phase719-preview-artifact]").count();

console.log("previewButtonCount:", previewCount);

if (previewCount > 0) {

  await previewButton.click();

  await page.waitForTimeout(1500);

  const modalMetrics = await page.evaluate(() => {

    const modal = document.querySelector("#phase719-preview-modal");

    const body = document.querySelector("#phase719-preview-body");

    const iframe = document.querySelector("#phase719-preview-body iframe");

    function rectFor(node) {

      if (!node) return null;

      const r = node.getBoundingClientRect();

      return {

        x: Math.round(r.x),

        y: Math.round(r.y),

        width: Math.round(r.width),

        height: Math.round(r.height),

        scrollHeight: node.scrollHeight,

        clientHeight: node.clientHeight,

        overflow: getComputedStyle(node).overflow,

        display: getComputedStyle(node).display,

      };

    }

    return {

      modal: rectFor(modal),

      body: rectFor(body),

      iframe: rectFor(iframe),

      iframeStyle: iframe ? iframe.getAttribute("style") : null,

      iframeSandbox: iframe ? iframe.getAttribute("sandbox") : null,

      modalDisplay: modal ? getComputedStyle(modal).display : null,

      modalHtmlLength: modal ? modal.innerHTML.length : 0,

    };

  });

  console.log("modalMetrics:");

  console.log(JSON.stringify(modalMetrics, null, 2));

  await page.screenshot({ path: "/tmp/phase719_preview_probe.png", fullPage: true });

  console.log("screenshot:/tmp/phase719_preview_probe.png");

}

console.log("consoleMessages:");

console.log(JSON.stringify(consoleMessages.slice(-30), null, 2));

await browser.close();

NODE

echo "[6] Run Playwright probe"

npx --yes playwright@latest install chromium >/tmp/phase719_playwright_install.log 2>&1 || {

  echo "Playwright browser install failed. See /tmp/phase719_playwright_install.log"

  exit 1

}

npx --yes playwright@latest node /tmp/phase719_browser_probe.mjs

echo ""

echo "===== PHASE 719 BROWSER AUTOMATION PROBE COMPLETE ====="

