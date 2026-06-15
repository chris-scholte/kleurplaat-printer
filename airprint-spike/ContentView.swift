// AirPrint silent-print test
//
// Goal: verify that UIPrintInteractionController.print(to: UIPrinter, ...) prints
// to a known AirPrint printer WITHOUT showing the iOS print dialog.
//
// Drop this file into a fresh Xcode "iOS App (SwiftUI)" project, replacing the
// default ContentView.swift. Add one of the downloaded test pages from
// content-spike/images/ to the Xcode project (drag in, "Copy items if needed",
// "Add to target"). Update `testFileName` below if you use a different file.
//
// Then build to a real device (Simulator can't reach AirPrint printers reliably
// — use an iPad or iPhone on the same Wi-Fi as your printer).

import SwiftUI
import UIKit

private let testFileName = "bear-coloring-page.jpg"        // bundled test artwork
private let savedPrinterURLKey = "kleurplaat.testPrinterURL"

struct ContentView: View {
    @State private var status: String = "Idle."
    @State private var savedPrinterURL: URL? = UserDefaults.standard.url(forKey: savedPrinterURLKey)

    var body: some View {
        VStack(spacing: 24) {
            Text("AirPrint Silent-Print Test")
                .font(.title2).bold()

            VStack(alignment: .leading, spacing: 4) {
                Text("Saved printer:")
                    .font(.caption).foregroundStyle(.secondary)
                Text(savedPrinterURL?.absoluteString ?? "— none —")
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(2)
                    .truncationMode(.middle)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))

            Button("1.  Pick AirPrint Printer (one time)") { pickPrinter() }
                .buttonStyle(.borderedProminent)

            Button("2.  Silent Print Test Page") { silentPrint() }
                .buttonStyle(.borderedProminent)
                .disabled(savedPrinterURL == nil)

            Text(status)
                .font(.callout)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
    }

    // MARK: - Step 1: pick a printer (this DOES show UI — that's expected, one-time)

    private func pickPrinter() {
        let picker = UIPrinterPickerController(initiallySelectedPrinter: nil)
        guard let root = UIApplication.shared
            .connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
            .first else {
            status = "Could not find root view controller."
            return
        }
        picker.present(animated: true, completionHandler: { _, userDidSelect, error in
            if let error {
                status = "Picker error: \(error.localizedDescription)"
                return
            }
            guard userDidSelect, let printer = picker.selectedPrinter else {
                status = "No printer selected."
                return
            }
            UserDefaults.standard.set(printer.url, forKey: savedPrinterURLKey)
            savedPrinterURL = printer.url
            status = "Saved printer: \(printer.displayName)"
            _ = root  // silence unused warning if compiler complains
        })
    }

    // MARK: - Step 2: silent print to the saved printer

    private func silentPrint() {
        guard let url = savedPrinterURL else {
            status = "No saved printer."
            return
        }
        guard let asset = Bundle.main.url(forResource: testFileName, withExtension: nil),
              let data = try? Data(contentsOf: asset) else {
            status = "Missing bundled file: \(testFileName)\nDid you add it to the Xcode target?"
            return
        }

        let printer = UIPrinter(url: url)
        printer.contactPrinter { reachable in
            DispatchQueue.main.async {
                guard reachable else {
                    status = "Printer unreachable. Wi-Fi? Powered on?"
                    return
                }

                let info = UIPrintInfo.printInfo()
                info.outputType = .general
                info.jobName = "kleurplaat-test"
                info.orientation = .portrait

                let controller = UIPrintInteractionController.shared
                controller.printInfo = info
                controller.printingItem = data
                controller.showsNumberOfCopies = false
                controller.showsPaperSelectionForLoadedPapers = false

                // THIS is the silent-print call — NO dialog should appear.
                controller.print(to: printer) { _, completed, error in
                    DispatchQueue.main.async {
                        if let error {
                            status = "Print failed: \(error.localizedDescription)"
                        } else if completed {
                            status = "✓ Print job sent silently. Did paper come out?"
                        } else {
                            status = "Print returned not-completed (no error)."
                        }
                    }
                }
            }
        }
    }
}

#Preview { ContentView() }
