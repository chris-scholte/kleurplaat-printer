# Kleurplaat Printer — Design Doc

> A native iOS app that lets young kids (4-7) autonomously pick and print colouring pages from a bundled library to a home AirPrint printer. Parents do a one-time setup; kids do everything else.

**Status:** Approved
**Mode:** Builder (open source side project)
**Date:** 2026-06-15
**Author:** chris.scholte@we-plus.be

---

## Problem

Parents of young kids regularly burn 10-15 minutes finding, downloading, and printing colouring pages — usually while the kid is already losing patience. The kid can't do it themselves: search engines, ad-laden colouring sites, print dialogs, and "is this even the right paper size?" all block them. Meanwhile, the parent has an iPad and an AirPrint-capable printer already sitting in the house doing nothing.

## Target user

- **Primary:** A 4-7 year old early reader. Recognizes pictures and category icons; can tap; cannot read paragraphs or navigate iOS settings.
- **Secondary:** Their parent. Wants to set this up once, walk away, and trust it.
- **Distribution audience:** Other parents in similar setups (iPad + AirPrint printer + early-reader kid). Open source via GitHub + App Store.

## Premises (locked)

1. Native iOS (Swift / SwiftUI). No web wrapper, no React Native.
2. No backend, no accounts, no cloud sync in v1. Everything local.
3. "Autonomous" = kid tap → print, no dialog. Uses `UIPrintInteractionController.print(to:)` with a known default printer to skip the picker UI.
4. Parent controls live behind Face ID / Touch ID / PIN fallback.
5. Content is bundled, CC0 / public-domain colouring pages curated by the maintainers. No scraping.

## Chosen approach: B with A scope for v1

Architect for an open-source contributor base from day one (modular content packs, localization keys, accessibility), but ship v1 with a deliberately small scope so a real kid uses it within a month.

### v1 scope (ships first)
- ~100-150 bundled PDF/PNG colouring pages, organized into 6-8 visual categories (animals, vehicles, dinosaurs, princesses, space, food, etc.).
- Kid mode is the default app launch state. Full-screen grid of category tiles → grid of page thumbnails → tap to print. No back-button mazes; one big "home" tile.
- Silent print to pre-configured default AirPrint printer. If the printer goes offline, show a kid-friendly "ask a grown-up" screen with a printer icon and sad face.
- Parent settings (behind Face ID): choose default printer, set daily print limit (default 10), toggle categories on/off, view today's print count.
- English UI only. NL/FR/DE strings stubbed but not localized.
- VoiceOver labels on every tappable thing. Dynamic Type ignored for kid UI (it's image-led), respected on parent screens.

### Deferred to v1.1+
- Profile per kid / favorites / streak
- Downloadable theme packs from a hosted index
- AI-generated colouring pages (the hybrid mode discussed)
- Multi-language UI beyond stubs
- Usage analytics dashboard for parents
- Apple Pencil pre-colouring (digital colouring before printing)

### Out of scope (probably ever)
- Cross-platform Android version (separate codebase / repo)
- Web app version
- Cloud accounts or content marketplace

## Architecture sketch

```
KleurplaatPrinter/
├── App/                         SwiftUI entrypoint, scene config
├── KidMode/                     Full-screen kid UI (grid, print confirmation animation)
├── ParentMode/                  Biometric-gated settings, printer picker, limits
├── Printing/                    AirPrint wrapper, silent-print logic, error states
├── Content/                     Bundled SPM module: pages + manifest.json
│   └── packs/
│       ├── animals/
│       ├── vehicles/
│       └── ...
├── Persistence/                 SwiftData models: PrintEvent, Settings
├── Localization/                .strings files, key constants
└── Tests/
```

**Key technical decisions:**
- **SwiftUI + iOS 17+** (SwiftData requires it; not a real constraint — kid uses modern iPad).
- **Content packs as SPM modules** so contributors can PR a self-contained `pack-unicorns/` directory with images + manifest.
- **`UIPrintInteractionController.print(to:)`** for silent printing — well-documented, works when default printer is configured.
- **Face ID via `LAContext`** with PIN fallback (kids might trigger Face ID accidentally; PIN backup matters).
- **SwiftData** for print event log (count today, count this week, simple).

## Distribution

- **GitHub repo:** public from day one. README with screenshots, kiosk-mode recipe (Approach C as docs), contributor guide for adding content packs.
- **TestFlight:** weekly builds via GitHub Actions + Fastlane.
- **App Store:** "Kids 6+" category, no IAP, no third-party analytics, full privacy nutrition label = "no data collected". This is the path of least resistance through review.

## Risks & open questions

| Risk | Mitigation |
|------|------------|
| AirPrint silent print silently fails on some printers | Test against 3-5 printer models before v1; document supported set |
| App Store rejects "Kids" category app for any minor issue | Read [App Store Kids Category guidelines](https://developer.apple.com/app-store/review/guidelines/#kids-category) carefully before first submission |
| Sourcing 150 CC0 colouring pages is harder than it sounds | Start with [openclipart.org](https://openclipart.org/) and [Wikimedia Commons](https://commons.wikimedia.org/); commission a few from Fiverr if needed; budget €100 |
| Kid finds a way out of the app | iOS Guided Access is the parent's job, not the app's. Document it. |
| Paper / ink cost runs away | Daily print limit (default 10) + parent gets a "5/10 prints today" hint in settings |

## What "done" looks like for v1

- Kid (yours) uses it for 30 minutes unsupervised, prints 5+ pages, doesn't ask for help once.
- App ships to TestFlight with 20+ pages in 3 categories.
- README has screenshots, install instructions, and "how to add a content pack" guide.
- 1 external person (friend with a kid + iPad) installs the TestFlight build and successfully prints.

## The Assignment

**This week, before writing any Swift code:**

1. **Find and download 30 CC0 colouring pages** from openclipart.org or similar. Put them in a `content-spike/` folder. If you can't find 30 pages you'd actually want your kid to use in an hour of searching, the content sourcing risk is real — and v1 might need a different sourcing strategy (commission an illustrator, partner with a creator).
2. **Test silent AirPrint from a 10-line throwaway iOS playground** against your actual printer. If `UIPrintInteractionController.print(to:)` doesn't print without UI on your hardware, the core UX is broken and we need to talk before committing more.

Both are ~2 hours. Both de-risk the design before any real code. If either fails, come back and we revise.

---

## Next steps (after the assignment passes)

- Set up Xcode project skeleton (single-target SwiftUI app, iOS 17+).
- Wire the AirPrint silent-print path with one hardcoded test PDF.
- Build the kid grid UI with placeholder tiles.
- Add Face ID parent gate + settings screen.
- Wire bundled content pack → grid.
- Polish, TestFlight, friend test, App Store submission.
