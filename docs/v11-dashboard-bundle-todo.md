# v11 Dashboard Bundling — Working TODO Snapshot

Branch: `feature/v11-dashboard-bundle`
Rollback tag: `v11.0-stable-dashboard`

## Next implementation step:
1. Backup dashboard.html:
   cp public/dashboard.html public/dashboard.pre-bundle-tag.html

2. Stream dashboard.html into ChatGPT:
   sed -n '1,200p' public/dashboard.html
   sed -n '200,400p' public/dashboard.html
   (continue until full file is provided)

3. ChatGPT will return a full replacement with:
   - <script src="bundle.js"></script> inserted near </body>
   - all existing scripts kept

4. Apply returned cat > public/dashboard.html block

5. Verify dashboard behavior:
   pnpm run build:dashboard-bundle
   lsof -i :3000 -i :3101 -i :3201

