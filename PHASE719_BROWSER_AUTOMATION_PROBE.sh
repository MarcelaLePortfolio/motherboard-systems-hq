
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 BROWSER AUTOMATION PROBE v3 ====="

echo ""

echo "[1] Runtime check"

docker compose ps

echo ""

echo "[2] Served JS confirmation"

curl -s http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -n "phase719-preview-modal\|phase719RenderArtifactIframePreview\|srcdoc\|width:min(760px,96vw)" || true

echo ""

echo "[3] Compact artifact task confirmation"

curl -s http://localhost:3000/api/tasks > /tmp/phase719_tasks.json

python3 << 'PY'

import json

with open("/tmp/phase719_tasks.json", "r") as f:

    data = json.load(f)

tasks = data.get("tasks", [])

print("ok:", data.get("ok"))

print("task_count:", len(tasks))

for t in tasks[:5]:

    artifact = t.get("artifact") or {}

    print({

        "id": t.get("id"),

        "status": t.get("status"),

        "has_artifact": bool(artifact),

        "artifact_type": artifact.get("type"),

        "artifact_source": artifact.get("source"),

    })

PY

echo ""

echo "[4] Write Playwright probe"

cat > /tmp/phase719_browser_probe.mjs << 'NODE'

import { chromium } from "playwright";

const browser = await chromium.launch({ headless: true });

const page = await browser.newPage({

  viewport: { width: 1440, height: 1000 }

});

const consoleMessages = [];

page.on("console", msg => {

  consoleMessages.push({

    type: msg.type(),

    text: msg.text()

  });

});

await page.goto("http://localhost:3000", {

  waitUntil: "domcontentloaded"

});

await page.waitForTimeout(1500);

const previewCount = await page.locator("[data-phase719-preview-artifact]").count();

console.log("previewButtonCount:", previewCount);

if (previewCount > 0) {

  await page.locator("[data-phase719-preview-artifact]").first().click();

  await page.waitForTimeout(2000);

  const metrics = await page.evaluate(() => {

    const modal = document.querySelector("#phase719-preview-modal");

    const dialog = modal

      ? modal.querySelector('[role="dialog"]')

      : null;

    const body = document.querySelector("#phase719-preview-body");

    const iframe = body

      ? body.querySelector("iframe")

      : null;

    function measure(node) {

      if (!node) return null;

      const rect = node.getBoundingClientRect();

      const style = getComputedStyle(node);

      return {

        width: Math.round(rect.width),

        height: Math.round(rect.height),

        clientHeight: node.clientHeight,

        scrollHeight: node.scrollHeight,

        overflow: style.overflow,

        display: style.display,

        inlineStyle: node.getAttribute("style")

      };

    }

    return {

      modal: measure(modal),

      dialog: measure(dialog),

      body: measure(body),

      iframe: measure(iframe),

      iframeSandbox: iframe

        ? iframe.getAttribute("sandbox")

        : null

    };

  });

  console.log("modalMetrics:");

  console.log(JSON.stringify(metrics, null, 2));

  await page.screenshot({

    path: "/tmp/phase719_preview_probe.png",

    fullPage: true

  });

  console.log("screenshot:/tmp/phase719_preview_probe.png");

}

console.log("consoleMessages:");

console.log(JSON.stringify(consoleMessages.slice(-20), null, 2));

await browser.close();

NODE

echo "[5] Run Playwright probe"

npm exec --yes --package=playwright@latest -- node /tmp/phase719_browser_probe.mjs

echo ""

echo "===== PHASE 719 BROWSER AUTOMATION PROBE v3 COMPLETE ====="

