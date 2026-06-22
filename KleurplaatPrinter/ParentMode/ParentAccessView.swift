import LocalAuthentication
import SwiftUI

struct ParentAccessView: View {
    @ObservedObject var printService: AirPrintService

    @Environment(\.dismiss) private var dismiss
    @State private var isUnlocked = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isUnlocked {
                    ParentSettingsView(printService: printService)
                } else {
                    lockedView
                }
            }
            .navigationTitle("Parent Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var lockedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64, weight: .semibold))
                .foregroundStyle(.blue)

            Text("Parent settings are locked")
                .font(.title2.weight(.bold))

            Button {
                unlock()
            } label: {
                Label("Unlock", systemImage: "lock.open.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private func unlock() {
        Task {
            let context = LAContext()
            let reason = "Unlock printer setup and daily print limits."

            do {
                isUnlocked = try await context.evaluatePolicy(
                    .deviceOwnerAuthentication,
                    localizedReason: reason
                )
                errorMessage = nil
            } catch {
                errorMessage = "Could not unlock parent settings."
            }
        }
    }
}

#Preview("Parent Lock") {
    ParentAccessView(printService: PreviewSupport.printService)
}
