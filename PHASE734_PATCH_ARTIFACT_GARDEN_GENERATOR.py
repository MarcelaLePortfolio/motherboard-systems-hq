
from pathlib import Path

path = Path("server/worker/task_execution_interpreter.mjs")

text = path.read_text()

start = text.index("function buildVisualArtifactOutput(title = \"\") {")

end = text.index("\nexport function interpretTaskExecution", start)

new_function = r'''function buildVisualArtifactOutput(title = "") {

  const source = String(title || "");

  const safeTitle = escapeHtml(source);

  const isArtifactGarden = /artifact\s+garden|intent\s+seed|snapshot\s+seed|preview\s+flower|matilda\s+guardian|locked\s+execution\s+gate|reconciliation\s+watering/i.test(source);

  if (isArtifactGarden) {

    return `# Artifact Garden Visual Artifact

<!-- visual-artifact:start -->

<div style="font-family: ui-serif, Georgia, 'Times New Roman', serif; border:1px solid rgba(156,103,126,.28); border-radius:30px; padding:34px; background:radial-gradient(circle at 18% 16%, rgba(255,245,213,.92), transparent 28%), radial-gradient(circle at 82% 10%, rgba(244,214,222,.80), transparent 30%), linear-gradient(135deg,#fff7e8,#f9e4e8 48%,#eef3dc); color:#5b2444; box-shadow:0 28px 90px rgba(91,36,68,.18); overflow:hidden;">

  <div style="text-align:center; margin-bottom:28px;">

    <div style="font-size:56px; line-height:1; font-weight:900; letter-spacing:-.04em; color:#6d2550;">Artifact Garden</div>

    <div style="margin-top:12px; font-size:18px; color:#8b5770;">

      Preview-only&nbsp;&nbsp;•&nbsp;&nbsp;Execution locked&nbsp;&nbsp;•&nbsp;&nbsp;Read-only visual artifact

    </div>

    <div style="display:inline-block; margin-top:14px; border:1px solid rgba(181,111,132,.26); background:rgba(255,247,248,.68); border-radius:999px; padding:10px 18px; color:#7a3d5b; font-size:17px;">

      Matilda observes, does not execute

    </div>

  </div>

  <div style="position:relative; min-height:610px; border:1px solid rgba(197,148,117,.18); border-radius:28px; padding:26px; background:linear-gradient(180deg,rgba(255,252,238,.72),rgba(248,232,214,.56)); box-shadow:inset 0 1px 0 rgba(255,255,255,.7);">

    <div style="position:absolute; left:7%; top:10%; width:180px;">

      <div style="font-size:72px;">🌱</div>

      <div style="border:1px solid rgba(186,145,112,.24); background:rgba(255,248,232,.82); border-radius:20px; padding:16px;">

        <div style="font-size:20px; font-weight:900; color:#6d2550;">Intent Seed</div>

        <div style="font-size:14px; line-height:1.45; color:#6f4b5d;">The original user intent, planted clearly.</div>

      </div>

    </div>

    <div style="position:absolute; left:8%; top:55%; width:210px;">

      <div style="font-size:68px;">🌾</div>

      <div style="border:1px solid rgba(186,145,112,.24); background:rgba(255,248,232,.84); border-radius:20px; padding:16px;">

        <div style="font-size:20px; font-weight:900; color:#6d2550;">Snapshot Seed Packet</div>

        <div style="font-size:14px; line-height:1.45; color:#6f4b5d;">A sealed checkpoint of the request.</div>

      </div>

    </div>

    <div style="position:absolute; left:39%; top:24%; width:210px; text-align:center;">

      <div style="font-size:92px;">🌸</div>

      <div style="border:1px solid rgba(181,111,132,.22); background:rgba(255,244,247,.86); border-radius:22px; padding:18px;">

        <div style="font-size:22px; font-weight:900; color:#6d2550;">Preview Flower</div>

        <div style="font-size:14px; line-height:1.45; color:#6f4b5d;">The artifact blooms visually here.</div>

      </div>

    </div>

    <div style="position:absolute; right:8%; top:14%; width:215px;">

      <div style="font-size:80px;">🏮</div>

      <div style="border:1px solid rgba(197,148,117,.26); background:rgba(255,244,232,.86); border-radius:22px; padding:18px;">

        <div style="font-size:21px; font-weight:900; color:#6d2550;">Matilda Guardian Lantern</div>

        <div style="font-size:14px; line-height:1.45; color:#6f4b5d;">Observes and interprets without executing.</div>

      </div>

    </div>

    <div style="position:absolute; right:9%; top:55%; width:220px;">

      <div style="font-size:86px;">🚪🔒</div>

      <div style="border:1px solid rgba(181,111,132,.24); background:rgba(255,244,247,.88); border-radius:22px; padding:18px;">

        <div style="font-size:21px; font-weight:900; color:#6d2550;">Locked Execution Gate</div>

        <div style="font-size:14px; line-height:1.45; color:#6f4b5d;">Execution locked. No mutations will be taken.</div>

      </div>

    </div>

    <div style="position:absolute; left:38%; bottom:6%; width:235px; text-align:center;">

      <div style="font-size:86px;">🪴💧</div>

      <div style="border:1px solid rgba(128,155,113,.28); background:rgba(245,250,232,.88); border-radius:22px; padding:18px;">

        <div style="font-size:21px; font-weight:900; color:#6d2550;">Reconciliation Watering Can</div>

        <div style="font-size:14px; line-height:1.45; color:#6f4b5d;">For alignment, confirmation, and recovery.</div>

      </div>

    </div>

    <div style="position:absolute; left:24%; top:42%; width:52%; height:1px; border-top:5px dotted rgba(170,130,96,.36); transform:rotate(7deg);"></div>

    <div style="position:absolute; left:22%; top:53%; width:56%; height:1px; border-top:5px dotted rgba(170,130,96,.30); transform:rotate(-10deg);"></div>

  </div>

  <div style="display:grid; grid-template-columns:repeat(4,minmax(0,1fr)); gap:14px; margin-top:22px;">

    <div style="background:rgba(255,244,247,.76); border:1px solid rgba(181,111,132,.20); border-radius:18px; padding:16px; color:#6d2550;">👁️ <b>Preview-only</b><br><span style="color:#7c5870;">Read-only mode</span></div>

    <div style="background:rgba(255,244,247,.76); border:1px solid rgba(181,111,132,.20); border-radius:18px; padding:16px; color:#6d2550;">🔒 <b>Execution locked</b><br><span style="color:#7c5870;">No execution bridge</span></div>

    <div style="background:rgba(255,248,232,.76); border:1px solid rgba(197,148,117,.22); border-radius:18px; padding:16px; color:#6d2550;">🏮 <b>Matilda observes</b><br><span style="color:#7c5870;">Does not execute</span></div>

    <div style="background:rgba(245,250,232,.76); border:1px solid rgba(128,155,113,.24); border-radius:18px; padding:16px; color:#6d2550;">🌿 <b>Read-only artifact</b><br><span style="color:#7c5870;">Visual validation</span></div>

  </div>

</div>

<!-- visual-artifact:end -->

## Request

${safeTitle}`;

  }

  const brand = inferBrandName(title);

  const safeBrand = escapeHtml(brand);

  const headline = /moonrise/i.test(brand)

    ? "Warm pastries for quiet mornings."

    : `A polished visual concept for ${safeBrand}.`;

  return `# ${safeBrand} Visual Artifact

<!-- visual-artifact:start -->

<div style="border:1px solid rgba(251,191,36,.35);border-radius:26px;padding:26px;background:linear-gradient(135deg,rgba(30,41,59,.96),rgba(120,53,15,.34));box-shadow:0 22px 70px rgba(0,0,0,.28);">

  <div style="display:flex;justify-content:space-between;gap:18px;align-items:flex-start;margin-bottom:22px;">

    <div>

      <div style="font-size:11px;text-transform:uppercase;letter-spacing:.2em;color:#fde68a;font-weight:900;margin-bottom:10px;">${safeBrand}</div>

      <div style="font-size:34px;line-height:1.02;font-weight:950;color:#fff7ed;margin-bottom:12px;">${headline}</div>

      <div style="font-size:15px;line-height:1.7;color:#fed7aa;max-width:620px;">A warm, premium preview card generated automatically from the delegation request.</div>

    </div>

    <div style="border:1px solid rgba(253,230,138,.35);border-radius:999px;padding:9px 13px;color:#fef3c7;background:rgba(120,53,15,.28);font-size:12px;font-weight:800;white-space:nowrap;">Preview Ready</div>

  </div>

</div>

<!-- visual-artifact:end -->

## Request

${safeTitle}`;

}

'''

path.write_text(text[:start] + new_function + text[end:])

print("patched artifact garden generator")

