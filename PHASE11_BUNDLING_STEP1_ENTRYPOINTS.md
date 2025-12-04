
Phase 11 – Dashboard Bundling STEP 1: Dashboard JS Entrypoints

This file is the authoritative map for all JavaScript entrypoints currently powering the Phase 11 dashboard.
It will be used to design the bundling strategy and verify behavior after bundling.

0. Project Context

Repo: Motherboard_Systems_HQ

Branch: feature/v11-dashboard-bundle

Phase: 11 – Dashboard Bundling & Reliability

Important constraint: All DB-backed work is deferred to Phase 11.5 – DB Task Storage.

Do not modify or reason about database schemas, pools, or DB-backed endpoints as part of this step.

1. Dashboard Template Discovery (Completed)

From the latest filesystem inspection:

There is no src/ directory.

There is no views/ directory.

The active dashboard HTML lives under public/.

1.1 Primary Dashboard Template

Path: public/dashboard.html

Notes: Standalone HTML file that serves as the main Phase 11 dashboard UI.

1.2 Related Dashboard Variants / Backups

These are historical or backup variants of the dashboard HTML. They are not the active template but are useful reference during bundling:

public/dashboard.pre-bundle-tag.html

public/dashboard.html.bak

public/dashboard.html.bad_structure

public/dashboard.html.bak_1762372376

public/dashboard.html.bak.1762457360

public/dashboard.html.bak_1762904490

public/dashboard.html.bak_1762905357

public/dashboard.html.bak_9.7.0b

You may consult these if needed to understand how scripts evolved, but all STEP 1 mapping should reflect the current public/dashboard.html.

2. Scope of STEP 1

In this step, you will:

Identify every JavaScript file currently loaded by public/dashboard.html.

Note the order in which scripts are loaded.

Note each script’s type (module, classic, or inline).

Note each script’s role (Matilda Chat, Task Delegation, SSE, layout, utilities, etc.).

Record any obvious dependencies or ordering constraints.

You will not change any JS or HTML as part of STEP 1 — this is a mapping/documentation step only.

3. STEP 1A – Raw Script Tag Inventory (TO FILL IN)

Using public/dashboard.html as the source of truth, list every <script> tag in the exact order they appear.

3.1 Suggested Commands to Inspect dashboard.html

You can use these while working (they are examples, not mandatory):

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

# See script tags in the active dashboard file
rg "<script" public/dashboard.html -n || cat public/dashboard.html

# If needed, compare with a pre-bundle version
rg "<script" public/dashboard.pre-bundle-tag.html -n || cat public/dashboard.pre-bundle-tag.html

3.2 Script Tag Table

Fill this table based on public/dashboard.html:

Order	Script Path / Identifier	Type	Role / Responsibility	Comments
1				
2				
3				
4				
5				
6				
7				
8				

Add more rows if needed. Use one row per <script> tag, including inline scripts (mark Script Path / Identifier as inline and briefly describe what it does).

4. STEP 1B – Group Scripts by Functional Area (TO FILL IN)

Once the raw list is done, group scripts by what they do. This will directly influence how we bundle.

4.1 Core Dashboard / Layout

Scripts that:

Initialize the dashboard

Handle layout, card visibility, tab switching

Wire up generic DOM behavior

Scripts:

4.2 Matilda Chat

Scripts that:

Handle /api/chat (or equivalent) calls

Attach submit handlers to the chat input / form

Render chat responses into the UI

Scripts:

4.3 Task Delegation

Scripts that:

Handle task delegation form submissions / buttons

Call task-related endpoints

Render delegation results or confirmations

Scripts:

4.4 SSE – Reflections / OPS / Other Streams

Scripts that:

Create EventSource instances

Subscribe to /events/reflections, /events/ops, etc.

Update DOM sections with live messages

Scripts:

4.5 Shared Utilities / Vendor Scripts

Scripts that:

Provide shared helpers (DOM utilities, formatting, etc.)

Represent vendor or library code used by multiple features

Scripts:

5. STEP 1C – Ordering & Dependency Notes (TO FILL IN)

Use this section to capture anything you notice about load order and dependencies, such as:

“Script A must load before Script B because it defines window.esOps.”

“This file assumes document.getElementById('matilda-chat-form') already exists.”

“This script attaches listeners that will break if run twice.”

Notes:

6. STEP 1D – Known Pain Points to Watch During Bundling

From prior Phase 11 work, key issues to watch for:

Double event listeners after page reload.

Multiple EventSource instances for the same endpoint.

Scripts re-attaching DOM handlers without cleanup.

Reliance on globals hanging off window.

While reviewing the scripts and dashboard.html, add any concrete issues you notice here:

Pain points / risks observed:

7. STEP 1E – Convenience Commands (Reference)

These are terminal commands you can reuse while filling out this file. They are for your convenience only and do not modify any files:

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

# List dashboard-related HTML
ls public/dashboard* public/*dashboard* || true

# Inspect script tags in active dashboard
rg "<script" public/dashboard.html -n || cat public/dashboard.html

# Inspect other dashboard JS files quickly
ls public/*.js public/scripts public/js 2>/dev/null || true

# Search for SSE usage
rg "EventSource" -n public || true

# Search for Matilda-related code
rg "matilda" -n public routes || true

# Search for delegation-related code
rg "delegate" -n public routes || true
rg "task" -n public routes || true


You can paste new commands into this section as you work, but do not remove the core STEP 1 structure above.

8. Completion Criteria for STEP 1

Mark STEP 1 as complete when:

 public/dashboard.html is confirmed as the primary template (done above).

 All script tags in public/dashboard.html are listed in the table with:

 Order

 Path / Identifier

 Type

 Role

 Scripts are grouped by functional area.

 Any load-order dependencies or pain points are noted.

When these are checked, you are ready for:

STEP 2 – Design the bundling strategy (single bundle entrypoint and vendor handling).
