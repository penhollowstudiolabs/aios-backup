# Rendering an HTML chart/diagram to PNG for Avi (8/15)

When Avi wants a visual artifact (role chart, diagram, dashboard, any styled graphic)
"to put on my desktop" or delivered via Telegram, do NOT use an image-generation
model — they garble text. Build a hand-crafted HTML/SVG so the text is crisp, then
render it to PNG with the browser. Proven 8/15 (Agent Role Calibration chart).

## Why not image_gen
Text-to-image models mangle labels/words. For anything with real text (names, roles,
bullets, rules), HTML+CSS/SVG is the only way to get legible output. The
`architecture-diagram` skill (creative/) has a good dark-theme design system to
reuse as a starting point.

## The rendering recipe (verified)
1. **Write the HTML file** (self-contained, inline CSS/SVG, no JS needed). Save to
   a vault location so it syncs, e.g. `/root/vault/AIOS/<Name>.html`.
2. **Browser won't load `file://` URLs** — the navigation tool blocks private/
   internal addresses. Serve over localhost instead:
   ```bash
   # start (background=true — it's a server)
   cd /root/vault/AIOS && python3 -m http.server 8899 --bind 127.0.0.1
   # readiness check in a SEPARATE command
   curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:8899/<Name>.html"   # 200
   ```
3. **Navigate + screenshot:**
   - `browser_navigate` → `http://127.0.0.1:8899/<Name>.html` (URL-encode spaces: `%20`)
   - `browser_vision` (question: "is it clean and legible, all sections visible?") —
     returns a `screenshot_path` PNG.
4. **Copy the PNG to a desktop-ready vault path** (keep the same base name as the
   .html):
   ```bash
   cp <screenshot_path> /root/vault/AIOS/<Name>-Chart.png
   ```
5. **Stop the server** (`process` → kill the background session).
6. **Deliver** via `MEDIA:/root/vault/AIOS/<Name>-Chart.png` in the reply. Keep the
   editable `.html` too so Avi can tweak text/colors later.

## Notes
- The `.html` and `.png` both live in the vault → they sync to laptop/iPhone via
  ob-sync automatically.
- Avi's desktop target: right-click PNG → Set as desktop background. The dark
  theme (slate-950 bg, 40px grid, color-coded agent cards) reads well as wallpaper.
- Keep the PNG square-ish or landscape per the layout; the screenshot captures the
  full page height.
