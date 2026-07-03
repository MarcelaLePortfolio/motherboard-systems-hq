
from pathlib import Path

import re

p = Path("public/dashboard.html")

s = p.read_text()

s = re.sub(

    r'<header class="phase59-shell[^"]*">',

    '<header class="phase59-shell mb-6">',

    s,

    count=1,

)

s = re.sub(

    r'<div class="flex items-center">\s*<h1 class="[^"]*">\s*Motherboard Systems Dashboard\s*</h1>\s*</div>\s*',

    '',

    s,

    count=1,

)

s = s.replace(

    'class="bg-gray-800 border border-gray-700 rounded-2xl shadow-xl px-4 py-3 flex flex-wrap items-center gap-x-5 gap-y-2"',

    'class="bg-gray-800 border border-gray-700 rounded-2xl shadow-xl px-5 py-4 flex flex-wrap items-center justify-between gap-x-6 gap-y-3"',

    1,

)

marker = '<button\n  id="project-context-selector"'

title = '''<div class="text-3xl font-extrabold tracking-tight text-gray-100 whitespace-nowrap">

        Motherboard Systems Dashboard

      </div>

      <div class="flex flex-wrap items-center gap-x-5 gap-y-2">

      '''

if "text-3xl font-extrabold tracking-tight text-gray-100 whitespace-nowrap" not in s:

    s = s.replace(marker, title + marker, 1)

s = s.replace(

    'PROBE LIFECYCLE AND TASK ACTIVITY VISIBLE BELOW.',

    'Probe lifecycle and task activity visible below.',

    1,

)

s = s.replace(

    '''      </span>

    </div>

</header>''',

    '''      </span>

      </div>

    </div>

</header>''',

    1,

)

p.write_text(s)

