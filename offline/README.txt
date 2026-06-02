EIF Visual QA Audit Platform — Offline Edition (v1.5.0)
=======================================================

This is a fully self-contained, offline build. No internet connection is
required: Tailwind CSS and JSZip are bundled locally in the ./vendor folder.

HOW TO USE
----------
1. Keep index.html and the vendor/ folder together (don't separate them).
2. Double-click index.html to open it in any modern browser
   (Chrome/Edge recommended for the "Photos Local Folder" picker).
3. Choose your model engine in the top-right:
     - "Local LM Studio (Offline)": point it at your local server
       (e.g. http://localhost:1234) to run 100% offline, end to end.
     - "Google Gemini API (Cloud)": requires internet + an API key
       (this option only is online; everything else works offline).
4. Load your GIS Shapefile ZIP and your photo plates (folder or ZIP),
   then audit rows individually, in batch, or export results to CSV.

NOTES
-----
- All file processing happens locally in your browser; nothing is uploaded
  except the single image bytes sent to Gemini if you choose the cloud engine.
- Settings (engine, key, server URL) are remembered in your browser.
- Version is shown as a badge next to the title and logged to the console.

CONTENTS
--------
  index.html            The application
  vendor/tailwind.css   Prebuilt Tailwind stylesheet (offline)
  vendor/jszip.min.js   JSZip library (offline)
