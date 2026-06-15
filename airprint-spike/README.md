# AirPrint Silent-Print Spike

Verify the core technical assumption of the DESIGN.md: that
`UIPrintInteractionController.print(to: UIPrinter, ...)` prints to a known
AirPrint printer **without showing the iOS print dialog**.

If this works on your printer, the "kid taps picture → paper comes out" UX is feasible.
If it doesn't, the design needs to be revisited before any real code gets written.

## Setup (5 minutes)

1. Open Xcode (16 or later).
2. `File > New > Project... > iOS > App`.
   - Product Name: `AirPrintSpike`
   - Interface: **SwiftUI**
   - Language: **Swift**
3. Replace the default `ContentView.swift` with the one in this folder.
4. Drag one test image from `../content-spike/images/` into the project navigator.
   - Recommended: `bear-coloring-page.jpg` (default in the code; change `testFileName` if you pick a different one).
   - When prompted: **"Copy items if needed" ON**, **"Add to target: AirPrintSpike" ON**.
5. Connect your iPad or iPhone via USB (or wireless debugging). **Don't use the Simulator** — the Simulator can't reliably reach physical AirPrint printers.
6. Make sure the device and the AirPrint printer are on the same Wi-Fi.
7. Hit **Run** (Cmd-R). First time, you'll need to trust the developer profile on the device (`Settings > General > VPN & Device Management`).

## Test protocol

1. Tap **"1. Pick AirPrint Printer"**. The standard iOS printer picker appears — this is fine (it's the parent-setup ritual from the design doc). Select your printer.
2. Status text should now say `Saved printer: <name>`.
3. Tap **"2. Silent Print Test Page"**.
4. **Observe carefully:**
   - **PASS:** no dialog appears, the status updates to `✓ Print job sent silently. Did paper come out?`, and within a few seconds the printer produces a page of the test artwork.
   - **PARTIAL PASS:** a small status / progress overlay appears briefly but does not require user interaction, and the page still prints. This is acceptable — kids won't be blocked.
   - **FAIL:** a print confirmation dialog requiring a tap appears. This kills the core UX. Report this back — we need to redesign.
   - **FAIL:** "Print failed" status. Note the error message verbatim and report back.

## Expected behaviour vs. risks

Apple's documentation says `print(to:completionHandler:)` (the `UIPrinter` overload, used here) prints without UI. In practice some printers reportedly behave differently — silent print should work on virtually all modern AirPrint printers, but worth confirming on your specific hardware.

If the result is FAIL, options to discuss:
- Use `present(animated:)` with a default printer pre-selected (1 confirmation tap, not full picker).
- Switch to a CUPS/IPP path via a small intermediary (more work, not iOS-native).
- Build a kiosk approach (Approach C from the design doc) where one parent confirmation per session is OK.

## Cleanup

This `airprint-spike/` directory and the throwaway Xcode project can be deleted once the test result is recorded. Don't carry the spike code into the real project.
