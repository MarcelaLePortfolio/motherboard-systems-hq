
from pathlib import Path

import re

p = Path("public/dashboard.html")

s = p.read_text()

button_pattern = re.compile(

    r'<button\s+id="project-context-selector"[\s\S]*?</button>',

    re.M,

)

menu_block = '''<div id="project-context-wrapper" class="relative">

        <button

          id="project-context-selector"

          type="button"

          class="rounded-full border border-teal-400/30 bg-gray-800/80 px-4 py-2 text-sm font-semibold text-teal-100 shadow-xl hover:border-teal-300/60 hover:bg-gray-800"

          aria-haspopup="true"

          aria-expanded="false"

        >

          Motherboard HQ ▼

        </button>

        <div

          id="project-context-menu"

          class="absolute left-0 top-full z-50 mt-3 hidden w-72 rounded-2xl border border-gray-700 bg-gray-900/98 p-3 shadow-2xl"

        >

          <div class="px-3 pb-3 text-sm font-semibold text-teal-100">Motherboard HQ</div>

          <div class="border-t border-gray-700 pt-2">

            <button type="button" class="w-full rounded-xl px-3 py-2 text-left text-sm text-gray-100 hover:bg-gray-800">Switch Project...</button>

          </div>

          <div class="mt-2 border-t border-gray-700 pt-2">

            <div class="px-3 py-1 text-xs uppercase tracking-[0.18em] text-gray-500">Recent Projects</div>

            <button type="button" class="w-full rounded-xl px-3 py-2 text-left text-sm text-teal-100 hover:bg-gray-800">Motherboard HQ</button>

            <button type="button" class="w-full rounded-xl px-3 py-2 text-left text-sm text-gray-300 hover:bg-gray-800">Executive Agent Suite</button>

            <button type="button" class="w-full rounded-xl px-3 py-2 text-left text-sm text-gray-300 hover:bg-gray-800">Crystal Vibes Wellness</button>

          </div>

          <div class="mt-2 border-t border-gray-700 pt-2">

            <button type="button" class="w-full rounded-xl px-3 py-2 text-left text-sm text-gray-100 hover:bg-gray-800">New Project...</button>

            <button type="button" class="w-full rounded-xl px-3 py-2 text-left text-sm text-gray-100 hover:bg-gray-800">Register Existing Project...</button>

          </div>

        </div>

      </div>'''

if "project-context-menu" not in s:

    s, count = button_pattern.subn(menu_block, s, count=1)

    if count != 1:

        raise SystemExit("Could not find project selector button")

script = '''<script>

(() => {

  const button = document.getElementById("project-context-selector");

  const menu = document.getElementById("project-context-menu");

  if (!button || !menu) return;

  const closeMenu = () => {

    menu.classList.add("hidden");

    button.setAttribute("aria-expanded", "false");

  };

  button.addEventListener("click", (event) => {

    event.stopPropagation();

    const isOpen = !menu.classList.contains("hidden");

    if (isOpen) {

      closeMenu();

    } else {

      menu.classList.remove("hidden");

      button.setAttribute("aria-expanded", "true");

    }

  });

  menu.addEventListener("click", (event) => {

    event.stopPropagation();

  });

  document.addEventListener("click", closeMenu);

  document.addEventListener("keydown", (event) => {

    if (event.key === "Escape") closeMenu();

  });

})();

</script>'''

if "const button = document.getElementById(\"project-context-selector\")" not in s:

    s = s.replace("</body>", script + "\n</body>", 1)

p.write_text(s)

