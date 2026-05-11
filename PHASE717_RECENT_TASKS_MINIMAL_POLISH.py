
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

replacements = [

    (

        'style="display:block;width:100%;min-width:0;max-width:100%;box-sizing:border-box;border:1px solid rgba(148,163,184,.22);border-radius:12px;padding:10px;margin:0 0 10px 0;background:rgba(15,23,42,.72);overflow:hidden;"',

        'style="display:block;width:100%;min-width:0;max-width:100%;box-sizing:border-box;border:1px solid rgba(148,163,184,.24);border-radius:14px;padding:12px;margin:0 0 12px 0;background:rgba(15,23,42,.74);overflow:hidden;"',

    ),

    (

        '<div style="margin-top:8px;border:1px solid rgba(71,85,105,.55);border-radius:10px;padding:7px;background:rgba(2,6,23,.22);">',

        '<div style="margin-top:10px;border:1px solid rgba(71,85,105,.55);border-radius:12px;padding:9px;background:rgba(2,6,23,.24);">',

    ),

    (

        '<div style="color:#cbd5e1;font-size:11px;font-weight:700;margin-bottom:5px;">Operator actions</div>',

        '<div style="color:#cbd5e1;font-size:11px;font-weight:700;margin-bottom:7px;letter-spacing:.02em;">Operator actions</div>',

    ),

    (

        '<div style="display:flex;flex-wrap:wrap;gap:6px;">',

        '<div style="display:flex;flex-wrap:wrap;gap:7px;align-items:center;">',

    ),

    (

        'style="margin-top:8px;cursor:pointer;border:1px solid rgba(147,197,253,.35);background:rgba(30,64,175,.14);color:#93c5fd;border-radius:999px;padding:4px 8px;font-size:11px;">Inspect details</button>',

        'style="margin-top:10px;cursor:pointer;border:1px solid rgba(147,197,253,.35);background:rgba(30,64,175,.14);color:#93c5fd;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect details</button>',

    ),

    (

        'style="margin-top:6px;margin-left:6px;cursor:pointer;border:1px solid rgba(251,191,36,.38);background:rgba(120,53,15,.14);color:#fbbf24;border-radius:999px;padding:4px 8px;font-size:11px;">Inspect trace</button>',

        'style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(251,191,36,.38);background:rgba(120,53,15,.14);color:#fbbf24;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect trace</button>',

    ),

    (

        'style="margin-top:6px;margin-left:6px;cursor:pointer;border:1px solid rgba(45,212,191,.38);background:rgba(20,83,45,.14);color:#5eead4;border-radius:999px;padding:4px 8px;font-size:11px;">Inspect logs</button>',

        'style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(45,212,191,.38);background:rgba(20,83,45,.14);color:#5eead4;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect logs</button>',

    ),

]

for old, new in replacements:

    if old not in text:

        raise SystemExit(f"Expected polish target not found:\n{old}")

    text = text.replace(old, new, 1)

path.write_text(text)

print("Applied minimal Recent Tasks polish only.")

