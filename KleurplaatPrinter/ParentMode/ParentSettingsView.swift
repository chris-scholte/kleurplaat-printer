import SwiftData
import SwiftUI

struct ParentSettingsView: View {
    @ObservedObject var printService: AirPrintService

    @AppStorage("dailyPrintLimit") private var dailyPrintLimit = 10
    @AppStorage(CategoryPreferences.disabledCategoryIDsKey) private var disabledCategoryIDsRaw = ""
    @AppStorage(CategoryPreferences.disabledAgeGroupIDsKey) private var disabledAgeGroupIDsRaw = ""
    @Query(sort: \PrintEvent.printedAt, order: .reverse) private var printEvents: [PrintEvent]

    private let library = ContentLibrary.main

    private var disabledCategoryIDs: Set<String> {
        CategoryPreferences.decode(disabledCategoryIDsRaw)
    }

    private var disabledAgeGroupIDs: Set<String> {
        CategoryPreferences.decode(disabledAgeGroupIDsRaw)
    }

    private var todaysPrintCount: Int {
        printEvents.filter { Calendar.current.isDateInToday($0.printedAt) }.count
    }

    var body: some View {
        List {
            Section("Printer") {
                LabeledContent("Default printer", value: printService.savedPrinterName)

                Button {
                    printService.presentPrinterPicker()
                } label: {
                    Label("Choose Printer", systemImage: "printer.fill")
                }
            }

            Section("Daily limit") {
                Stepper("Limit: \(dailyPrintLimit)", value: $dailyPrintLimit, in: 1...25)
                Text("\(todaysPrintCount) of \(dailyPrintLimit) prints used today")
                    .foregroundStyle(.secondary)
            }

            Section("Categories") {
                ForEach(library.categories) { category in
                    Toggle(isOn: categoryBinding(for: category.id)) {
                        Label(category.title, systemImage: category.symbolName)
                    }
                }
            }

            Section("Age groups") {
                ForEach(library.ageGroups) { ageGroup in
                    Toggle(isOn: ageGroupBinding(for: ageGroup.id)) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(ageGroup.title)
                            Text(ageGroup.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            CreditsSection(library: library)
        }
    }

    private func categoryBinding(for categoryID: String) -> Binding<Bool> {
        Binding(
            get: { !disabledCategoryIDs.contains(categoryID) },
            set: { isEnabled in
                var updated = disabledCategoryIDs

                if isEnabled {
                    updated.remove(categoryID)
                } else {
                    updated.insert(categoryID)
                }

                disabledCategoryIDsRaw = CategoryPreferences.encode(updated)
            }
        )
    }

    private func ageGroupBinding(for ageGroupID: String) -> Binding<Bool> {
        Binding(
            get: { !disabledAgeGroupIDs.contains(ageGroupID) },
            set: { isEnabled in
                var updated = disabledAgeGroupIDs

                if isEnabled {
                    updated.remove(ageGroupID)
                } else {
                    updated.insert(ageGroupID)
                }

                disabledAgeGroupIDsRaw = CategoryPreferences.encode(updated)
            }
        )
    }
}

private struct CreditsSection: View {
    let library: ContentLibrary

    var body: some View {
        Section("Credits") {
            ForEach(library.pages) { page in
                VStack(alignment: .leading, spacing: 6) {
                    Text(page.title)
                        .font(.headline)

                    Text("\(page.artist) · \(page.license)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let sourceURL = URL(string: page.source) {
                        Link("Source", destination: sourceURL)
                            .font(.footnote)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

#Preview("Parent Settings") {
    ParentSettingsView(printService: PreviewSupport.printService)
        .modelContainer(PreviewSupport.modelContainer)
}
