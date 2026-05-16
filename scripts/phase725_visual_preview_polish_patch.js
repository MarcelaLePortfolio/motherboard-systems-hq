
const fs = require("fs");

const file = "public/js/phase530_visible_panels_bridge.js";

let src = fs.readFileSync(file, "utf8");

const replacements = [

  [

    `<div data-phase723-visual-artifact-preview="true" style="max-width:920px;margin:0 auto 18px auto;border:1px solid rgba(45,212,191,.28);background:rgba(15,23,42,.62);border-radius:22px;padding:18px;box-shadow:0 18px 60px rgba(0,0,0,.24);">`,

    `<div data-phase723-visual-artifact-preview="true" style="max-width:960px;margin:0 auto 22px auto;border:1px solid rgba(45,212,191,.32);background:linear-gradient(135deg,rgba(15,23,42,.78),rgba(8,47,73,.46));border-radius:26px;padding:22px;box-shadow:0 24px 80px rgba(0,0,0,.32), inset 0 1px 0 rgba(255,255,255,.06);">`

  ],

  [

    `<div style="display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:14px;">`,

    `<div style="display:flex;align-items:center;justify-content:space-between;gap:14px;margin-bottom:18px;">`

  ],

  [

    `<div style="font-size:11px;text-transform:uppercase;letter-spacing:.18em;color:#99f6e4;font-weight:900;">Visual Artifact</div>`,

    `<div style="font-size:12px;text-transform:uppercase;letter-spacing:.2em;color:#ccfbf1;font-weight:950;text-shadow:0 0 22px rgba(45,212,191,.18);">Visual Artifact</div>`

  ],

  [

    `<div style="font-size:10px;text-transform:uppercase;letter-spacing:.14em;color:#bfdbfe;border:1px solid rgba(147,197,253,.28);border-radius:999px;padding:4px 8px;background:rgba(30,64,175,.16);">sanitized html subset</div>`,

    `<div style="font-size:10px;text-transform:uppercase;letter-spacing:.14em;color:#dbeafe;border:1px solid rgba(147,197,253,.34);border-radius:999px;padding:5px 10px;background:rgba(30,64,175,.22);box-shadow:inset 0 1px 0 rgba(255,255,255,.05);">sanitized html subset</div>`

  ],

  [

    `<div data-phase723-visual-artifact-body="true" style="overflow:auto;border-radius:16px;background:rgba(2,6,23,.38);border:1px solid rgba(148,163,184,.18);padding:14px;color:#e5e7eb;">`,

    `<div data-phase723-visual-artifact-body="true" style="overflow:auto;border-radius:20px;background:rgba(2,6,23,.46);border:1px solid rgba(148,163,184,.24);padding:18px;color:#e5e7eb;box-shadow:inset 0 1px 0 rgba(255,255,255,.04);">`

  ]

];

for (const [before, after] of replacements) {

  if (!src.includes(before)) {

    throw new Error("Expected visual Preview style string not found. Aborting without mutation.");

  }

  src = src.replace(before, after);

}

fs.writeFileSync(file, src);

