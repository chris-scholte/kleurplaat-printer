import SwiftData
import SwiftUI

enum PreviewSupport {
    @MainActor
    static let printService = AirPrintService()

    @MainActor
    static var modelContainer: ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: PrintEvent.self, configurations: configuration)
    }
}

