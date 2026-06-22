import Foundation
import UIKit

@MainActor
final class AirPrintService: ObservableObject {
    @Published private(set) var savedPrinterName = "No printer selected"
    @Published private(set) var hasSavedPrinter = false

    private let defaults: UserDefaults
    private let savedPrinterURLKey = "defaultPrinterURL"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        refreshSavedPrinter()
    }

    func presentPrinterPicker() {
        let picker = UIPrinterPickerController(initiallySelectedPrinter: savedPrinter)

        picker.present(animated: true) { [weak self] picker, userDidSelect, error in
            guard let self else { return }

            if let error {
                self.savedPrinterName = error.localizedDescription
                return
            }

            guard userDidSelect, let printer = picker.selectedPrinter else {
                self.refreshSavedPrinter()
                return
            }

            self.defaults.set(printer.url, forKey: self.savedPrinterURLKey)
            self.savedPrinterName = printer.displayName
            self.hasSavedPrinter = true
        }
    }

    func printBundledPage(_ page: ColoringPage) async throws {
        guard let fileURL = page.resourceURL() else {
            throw AirPrintError.missingResource(page.filename)
        }

        let data = try Data(contentsOf: fileURL)
        try await print(data: data, jobName: page.title)
    }

    private var savedPrinter: UIPrinter? {
        guard let url = defaults.url(forKey: savedPrinterURLKey) else { return nil }
        return UIPrinter(url: url)
    }

    private func refreshSavedPrinter() {
        guard let printer = savedPrinter else {
            savedPrinterName = "No printer selected"
            hasSavedPrinter = false
            return
        }

        savedPrinterName = printer.displayName
        hasSavedPrinter = true
    }

    private func print(data: Data, jobName: String) async throws {
        guard let printer = savedPrinter else {
            throw AirPrintError.noSavedPrinter
        }

        let reachable = await contact(printer)
        guard reachable else {
            throw AirPrintError.printerUnavailable
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let info = UIPrintInfo.printInfo()
            info.outputType = .general
            info.jobName = jobName

            let controller = UIPrintInteractionController.shared
            controller.printInfo = info
            controller.printingItem = data

            controller.print(to: printer) { _, completed, error in
                if let error {
                    continuation.resume(throwing: AirPrintError.jobFailed(error.localizedDescription))
                } else if completed {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: AirPrintError.cancelled)
                }
            }
        }
    }

    private func contact(_ printer: UIPrinter) async -> Bool {
        await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            printer.contactPrinter { reachable in
                continuation.resume(returning: reachable)
            }
        }
    }
}

enum AirPrintError: LocalizedError {
    case noSavedPrinter
    case missingResource(String)
    case printerUnavailable
    case cancelled
    case jobFailed(String)

    var errorDescription: String? {
        switch self {
        case .noSavedPrinter:
            return "Ask a grown-up to choose a printer."
        case .missingResource(let name):
            return "Missing print file: \(name)."
        case .printerUnavailable:
            return "The printer is not reachable."
        case .cancelled:
            return "The print job did not finish."
        case .jobFailed(let message):
            return message
        }
    }
}
