import Foundation
import SwiftData

@Model
final class PrintEvent {
    var id: UUID
    var pageID: String
    var pageTitle: String
    var printedAt: Date

    init(pageID: String, pageTitle: String, printedAt: Date = .now) {
        self.id = UUID()
        self.pageID = pageID
        self.pageTitle = pageTitle
        self.printedAt = printedAt
    }
}

