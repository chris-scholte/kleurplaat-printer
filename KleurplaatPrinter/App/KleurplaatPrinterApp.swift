import SwiftData
import SwiftUI

@main
struct KleurplaatPrinterApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: [PrintEvent.self])
    }
}

