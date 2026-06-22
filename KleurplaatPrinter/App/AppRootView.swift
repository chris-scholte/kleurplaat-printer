import SwiftUI

struct AppRootView: View {
    @StateObject private var printService = AirPrintService()
    @State private var showingParentSettings = false

    var body: some View {
        KidModeView(
            printService: printService,
            onOpenParentSettings: { showingParentSettings = true }
        )
        .fullScreenCover(isPresented: $showingParentSettings) {
            ParentAccessView(printService: printService)
        }
    }
}

