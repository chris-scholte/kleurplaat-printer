import SwiftData
import SwiftUI
import UIKit

struct KidModeView: View {
    @ObservedObject var printService: AirPrintService

    let onOpenParentSettings: () -> Void

    @Environment(\.modelContext) private var modelContext
    @AppStorage("dailyPrintLimit") private var dailyPrintLimit = 10
    @AppStorage(CategoryPreferences.disabledCategoryIDsKey) private var disabledCategoryIDsRaw = ""
    @AppStorage(CategoryPreferences.disabledAgeGroupIDsKey) private var disabledAgeGroupIDsRaw = ""
    @Query(sort: \PrintEvent.printedAt, order: .reverse) private var printEvents: [PrintEvent]

    @State private var selectedCategoryID: String?
    @State private var printState: PrintState = .idle

    private let library = ContentLibrary.main

    private var disabledCategoryIDs: Set<String> {
        CategoryPreferences.decode(disabledCategoryIDsRaw)
    }

    private var disabledAgeGroupIDs: Set<String> {
        CategoryPreferences.decode(disabledAgeGroupIDsRaw)
    }

    private var enabledAgeGroupIDs: Set<String> {
        Set(library.ageGroups.map(\.id)).subtracting(disabledAgeGroupIDs)
    }

    private var enabledCategories: [ColoringCategory] {
        library.categories.filter { category in
            !disabledCategoryIDs.contains(category.id)
                && !library.pages(in: category.id, enabledAgeGroupIDs: enabledAgeGroupIDs).isEmpty
        }
    }

    private var selectedCategory: ColoringCategory? {
        guard let selectedCategoryID else { return nil }
        return library.category(id: selectedCategoryID)
    }

    private var todaysPrintCount: Int {
        printEvents.filter { Calendar.current.isDateInToday($0.printedAt) }.count
    }

    private var canPrintToday: Bool {
        todaysPrintCount < dailyPrintLimit
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            if let category = selectedCategory {
                PageGridView(
                    category: category,
                    pages: library.pages(in: category.id, enabledAgeGroupIDs: enabledAgeGroupIDs),
                    printState: printState,
                    canPrintToday: canPrintToday,
                    onPrint: printPage
                )
            } else {
                CategoryGridView(
                    categories: enabledCategories,
                    onSelect: { selectedCategoryID = $0.id }
                )
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    private var header: some View {
        HStack(spacing: 16) {
            if selectedCategoryID != nil {
                Button {
                    selectedCategoryID = nil
                    printState = .idle
                } label: {
                    Label("Home", systemImage: "house.fill")
                        .font(.title3.weight(.bold))
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }

            Spacer()

            Button(action: onOpenParentSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.title2.weight(.semibold))
                    .frame(width: 52, height: 52)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Parent settings")
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(Color(.systemBackground))
    }

    private func printPage(_ page: ColoringPage) {
        guard printState != .printing else { return }

        guard canPrintToday else {
            printState = .limitReached
            return
        }

        printState = .printing

        Task { @MainActor in
            do {
                try await printService.printBundledPage(page)
                modelContext.insert(PrintEvent(pageID: page.id, pageTitle: page.title))
                try? modelContext.save()
                printState = .sent(page.title)
            } catch {
                printState = .failed(error.localizedDescription)
            }
        }
    }
}

private struct CategoryGridView: View {
    let categories: [ColoringCategory]
    let onSelect: (ColoringCategory) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 180, maximum: 260), spacing: 18)
    ]

    var body: some View {
        ScrollView {
            if categories.isEmpty {
                ContentUnavailableView(
                    "Ask a grown-up",
                    systemImage: "lock.fill",
                    description: Text("No pages are ready.")
                )
                .padding(32)
            } else {
                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(categories) { category in
                        Button {
                            onSelect(category)
                        } label: {
                            VStack(spacing: 18) {
                                Image(systemName: category.symbolName)
                                    .font(.system(size: 56, weight: .bold))
                                    .foregroundStyle(category.tint)

                                Text(category.title)
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, minHeight: 180)
                            .padding(20)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(category.title)
                    }
                }
                .padding(24)
            }
        }
    }
}

private struct PageGridView: View {
    let category: ColoringCategory
    let pages: [ColoringPage]
    let printState: PrintState
    let canPrintToday: Bool
    let onPrint: (ColoringPage) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 180, maximum: 260), spacing: 18)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(category.title)
                    .font(.largeTitle.weight(.bold))
                    .padding(.horizontal, 24)

                statusBanner
                    .padding(.horizontal, 24)

                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(pages) { page in
                        Button {
                            onPrint(page)
                        } label: {
                            VStack(spacing: 14) {
                                PageThumbnailView(page: page, tint: category.tint)

                                Text(page.title)
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)

                                Label("Print", systemImage: "printer.fill")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity, minHeight: 300)
                            .padding(14)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .disabled(!canPrintToday || printState == .printing)
                        .accessibilityLabel("Print \(page.title)")
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .padding(.top, 24)
        }
    }

    @ViewBuilder
    private var statusBanner: some View {
        if !canPrintToday {
            Label("All done for today", systemImage: "sun.max.fill")
                .statusStyle()
        } else {
            switch printState {
            case .idle:
                EmptyView()
            case .printing:
                Label("Sending to printer", systemImage: "printer")
                    .statusStyle()
            case .sent(let title):
                Label("\(title) is printing", systemImage: "checkmark.circle.fill")
                    .statusStyle()
            case .failed(let message):
                Label(message, systemImage: "exclamationmark.triangle.fill")
                    .statusStyle()
            case .limitReached:
                Label("All done for today", systemImage: "sun.max.fill")
                    .statusStyle()
            }
        }
    }
}

private struct PageThumbnailView: View {
    let page: ColoringPage
    let tint: Color

    @State private var thumbnail: UIImage?

    var body: some View {
        ZStack {
            Color.white

            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFit()
                    .padding(8)
            } else {
                Image(systemName: "doc.richtext.fill")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(tint)
            }
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.black.opacity(0.12), lineWidth: 1)
        }
        .task(id: page.id) {
            thumbnail = page.thumbnailImage()
        }
    }
}

private extension View {
    func statusStyle() -> some View {
        self
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

enum PrintState: Equatable {
    case idle
    case printing
    case sent(String)
    case failed(String)
    case limitReached
}

#Preview("Kid Mode") {
    KidModeView(
        printService: PreviewSupport.printService,
        onOpenParentSettings: {}
    )
    .modelContainer(PreviewSupport.modelContainer)
}
