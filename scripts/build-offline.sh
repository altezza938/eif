#!/usr/bin/env bash
#
# Build the fully-offline edition of the EIF audit app.
#
# Produces ./offline/ containing index.html rewired to local, bundled copies of
# Tailwind CSS (prebuilt, minified) and JSZip — so the app runs with no network.
# Optionally also produces a distributable zip.
#
# Usage:
#   ./scripts/build-offline.sh          # build ./offline/
#   ./scripts/build-offline.sh --zip    # also create eif-audit-offline.zip
#
# Requirements: node + npm (registry.npmjs.org reachable for the first build).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

JSZIP_VERSION="3.10.1"
TAILWIND_VERSION="3.4.17"
OUT="offline"

echo "==> Installing build dependencies (jszip@$JSZIP_VERSION, tailwindcss@$TAILWIND_VERSION)"
npm install --no-save "jszip@$JSZIP_VERSION" "tailwindcss@$TAILWIND_VERSION" >/dev/null

echo "==> Preparing $OUT/"
mkdir -p "$OUT/vendor"
cp index.html "$OUT/index.html"

echo "==> Bundling JSZip"
cp node_modules/jszip/dist/jszip.min.js "$OUT/vendor/jszip.min.js"

echo "==> Compiling Tailwind stylesheet (scanning index.html for used classes)"
printf '@tailwind base;\n@tailwind components;\n@tailwind utilities;\n' > "$OUT/.input.css"
npx --yes "tailwindcss@$TAILWIND_VERSION" \
  -i "$OUT/.input.css" \
  -o "$OUT/vendor/tailwind.css" \
  --content ./index.html \
  --minify
rm -f "$OUT/.input.css"

echo "==> Rewiring $OUT/index.html to local vendor files"
# Swap the CDN <script> tags for the local, prebuilt assets.
node - "$OUT/index.html" <<'NODE'
const fs = require('fs');
const file = process.argv[2];
let html = fs.readFileSync(file, 'utf8');
html = html
  .replace(/<script src="https:\/\/cdn\.tailwindcss\.com"><\/script>/,
           '<link rel="stylesheet" href="vendor/tailwind.css">')
  .replace(/<script src="https:\/\/cdnjs\.cloudflare\.com\/ajax\/libs\/jszip\/[^"]+"><\/script>/,
           '<script src="vendor/jszip.min.js"></script>');
fs.writeFileSync(file, html);
NODE

echo "==> Done. Offline build is in ./$OUT/"

if [[ "${1:-}" == "--zip" ]]; then
  ZIP="eif-audit-offline.zip"
  echo "==> Creating $ZIP"
  ( cd "$OUT" && zip -r -q "../$ZIP" . )
  echo "==> Wrote $ZIP"
fi
