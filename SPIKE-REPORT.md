# Spike Report

> Results from the two de-risking spikes called out in `DESIGN.md > The Assignment`.

**Date:** 2026-06-15
**Status:** Part 1 (content sourcing) DONE • Part 2 (AirPrint silent print) HANDED OFF — needs Chris to run

---

## Part 1: Content sourcing — DONE

### Headline

The strategy works, with a caveat on volume. Wikimedia Commons is a viable primary source for v1; expect to need one supplementary source to hit the 100-150 target.

### What was attempted

| Source | Result |
|---|---|
| **openclipart.org JSON API** | Dead. The API endpoint returns the HTML homepage. Discontinued at some point post-launch. |
| **publicdomainvectors.org** | Reachable but no public API; scraping required. Not used in this spike. |
| **freesvg.org** | Reachable but same issue. Not used. |
| **Wikimedia Commons API** | Live, well-documented, rate-limited. **Used as primary source for this spike.** |

### Sourcing pipeline (automated, repeatable)

1. Query the `Category:Coloring_pages` (153 files) and `Category:Line_drawings` (162 files) on Wikimedia Commons — 315 unique candidates.
2. Filter titles for kid-appropriate subjects (pattern: titles containing "coloring page", "coloring book", "for coloring", "color this", recognizable animal names).
3. For each candidate, query the API for image URL + license + artist metadata in one round trip.
4. Filter to safe licenses: CC0, Public Domain, CC BY 3.0/4.0, CC BY-SA 2.0/3.0/4.0.
5. Download with rate-limit-aware backoff (3-second spacing, retry on 429).
6. Compute SHA-256 + file size, build `manifest.json` with attribution.
7. Spot-check images for actual kid-appropriateness (titles can mislead).

Pipeline lives in this conversation's bash history — easy to re-run / extend to other categories or sources.

### Results

- **40 candidates queried**, all came back with safe licenses.
- **All 40 downloaded** (47 MB total) — see `content-spike/images/` and `content-spike/manifest.json`.
- **Kid-friendliness verdict** (after spot-checking):

| Verdict | Count | What it means |
|---|---:|---|
| ✅ **yes** | 29 | Cartoon style, simple lines, kid-appropriate. Ready for v1 bundling. |
| ⚠️ **usable-with-crop** | 5 | NPS Chesapeake Bay series + a Florida Manatee page — good illustrations, but the source files include educational paragraphs we'd crop out. |
| ❌ **skip** | 6 | Italian Renaissance "Illustrazione" engravings (peacock, fish, bird, deer) + a butcher's-cut calf diagram. Wrong audience entirely. |

- **License distribution** of the 40:
  - CC0 / Public Domain: **17** (no attribution required)
  - CC BY-SA 4.0 / 3.0 / 2.0: **21**
  - CC BY 3.0: **1**
  - GPL: **1** (probably skip — atypical for images, audit before bundling)
- **File formats:** mix of JPG (raster, often 2-4 MB each — large), PNG, GIF, SVG (preferred — scalable, small), PDF (preferred — print-ready).

### What this means for v1

- **29 kid-ready pages from one source in one afternoon** validates the bundled-library approach. Sourcing the full 100-150 is realistic but not free.
- **You will need a second source to hit the v1 target**, because the kid-appropriate ceiling from Wikimedia's two categories looks to be ~50-70 pages total. Options:
  1. Crawl a few more Wikimedia categories (animal illustrations, simple SVG drawings) — probably gets us to 70-90.
  2. Add the **U.S. National Park Service kids' activity catalog** (federal works = public domain, no attribution needed, dozens of pages already published as PDFs).
  3. Commission 30-50 pages on Fiverr (per the design doc's €100 budget line) — gives you guaranteed style consistency, the biggest visual problem of mixing multiple sources.
- **Ship the parent attribution screen in v1.** Half the pool is CC BY-SA — a single in-app "Credits" screen listing artist names + license types satisfies the obligation for the entire content set.
- **Bias toward SVG/PDF.** A 4 MB JPG × 150 pages = 600 MB in the app bundle, which the App Store will reject. SVGs in this batch are 7-100 KB. Either source vector content directly, or downsample/convert rasters to PDF on import.

### License-handling implications

- **CC0 / PD:** zero obligation. Use freely.
- **CC BY / CC BY-SA:** attribution required. Show artist + source + license in a Credits screen. CC BY-SA does *not* "infect" the app code — only the images stay CC BY-SA. Modifications to images (cropping, recolouring) must stay CC BY-SA.
- **GPL:** unusual for images. Audit before bundling; the one GPL image in this batch is Tux (Linux mascot). Probably fine, but flag for review.

---

## Part 2: AirPrint silent-print test — HANDED OFF

### Why I can't run it

This test needs:
- Your physical AirPrint printer
- An iPad or iPhone on your Wi-Fi
- Xcode 16+ on your Mac
- You watching whether a dialog appears

None of these are something I can drive autonomously.

### What's ready for you

`airprint-spike/` contains:
- `ContentView.swift` — a self-contained SwiftUI app with two buttons: pick printer, silent-print test PDF
- `README.md` — step-by-step setup (5 min), test protocol with PASS / PARTIAL PASS / FAIL criteria, and fallback options if it FAILs

### The test in one sentence

Tap "Pick Printer" once (dialog is expected — this is the one-time parent setup). Tap "Silent Print Test Page". If a page comes out of your printer *without a confirmation dialog appearing*, the core UX is feasible. If a dialog appears, the design needs to change.

### What I expect

`UIPrintInteractionController.print(to: UIPrinter, completionHandler:)` is documented to print without UI when given a known `UIPrinter`. In practice this works on the vast majority of modern AirPrint printers. The risk is non-zero but low.

### What to report back

- Printer make/model + iOS version (calibrates the result for the README)
- PASS / PARTIAL / FAIL + any error message verbatim
- Time-to-print (seconds from button tap to paper coming out)

---

## Recommendation

**Do not start the Xcode project skeleton yet.** Run the AirPrint test first. The whole "kid taps picture → paper" pitch lives or dies on that one verb (silent-print). If it works, the design is unchanged. If it doesn't, we need to talk before any real code gets written — Approach C (kiosk with one tap per session) or a fallback design becomes the new v1.

After AirPrint passes, the next concrete step is: source another 30-70 pages (NPS catalog is the cheapest path) + crop the 5 NPS Chesapeake pages already downloaded.

---

## Status

- **Part 1 (content sourcing):** DONE — 29 v1-ready pages + 5 usable-with-crop, sourcing pipeline validated.
- **Part 2 (AirPrint test):** NEEDS_USER_ACTION — playground in `airprint-spike/`, ~10 minutes to run.

**Recommended next move:** open `airprint-spike/README.md`, run the test, report back.
