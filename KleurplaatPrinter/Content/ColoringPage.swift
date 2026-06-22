import Foundation
import PDFKit
import SwiftUI
import UIKit

struct ColoringCategory: Identifiable, Decodable {
    let id: String
    let title: String
    let symbolName: String
    let colorName: String

    var tint: Color {
        switch colorName {
        case "green":
            return .green
        case "indigo":
            return .indigo
        case "pink":
            return .pink
        case "orange":
            return .orange
        case "blue":
            return .blue
        case "purple":
            return .purple
        case "teal":
            return .teal
        default:
            return .blue
        }
    }
}

struct AgeGroup: Identifiable, Decodable {
    let id: String
    let title: String
    let subtitle: String
    let styleName: String
}

struct ColoringPage: Identifiable, Decodable {
    let id: String
    let title: String
    let categoryID: String
    let ageGroupID: String
    let filename: String
    let mime: String
    let license: String
    let licenseURL: String
    let artist: String
    let source: String

    var resourceName: String {
        (filename as NSString).deletingPathExtension
    }

    var resourceExtension: String {
        (filename as NSString).pathExtension
    }

    func resourceURL(in bundle: Bundle = .main) -> URL? {
        guard let resourceURL = bundle.resourceURL else { return nil }

        let url = resourceURL
            .appendingPathComponent(ContentLibrary.resourceSubdirectory)
            .appendingPathComponent(filename)

        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    func thumbnailImage(in bundle: Bundle = .main, maxDimension: CGFloat = 320) -> UIImage? {
        guard let url = resourceURL(in: bundle) else { return nil }

        if mime == "application/pdf" {
            return PDFDocument(url: url)?
                .page(at: 0)?
                .thumbnail(
                    of: CGSize(width: maxDimension, height: maxDimension * 1.35),
                    for: .mediaBox
                )
        }

        return UIImage(contentsOfFile: url.path)
    }
}

struct ContentManifest: Decodable {
    let ageGroups: [AgeGroup]
    let categories: [ColoringCategory]
    let pages: [ColoringPage]
}

struct ContentLibrary {
    static let resourceSubdirectory = "generated-v2"
    static let main = load()

    let ageGroups: [AgeGroup]
    let categories: [ColoringCategory]
    let pages: [ColoringPage]

    func pages(in categoryID: String) -> [ColoringPage] {
        pages.filter { $0.categoryID == categoryID }
    }

    func pages(in categoryID: String, enabledAgeGroupIDs: Set<String>) -> [ColoringPage] {
        pages.filter { page in
            page.categoryID == categoryID && enabledAgeGroupIDs.contains(page.ageGroupID)
        }
    }

    func category(id: String) -> ColoringCategory? {
        categories.first { $0.id == id }
    }

    private static func load(bundle: Bundle = .main) -> ContentLibrary {
        guard let url = bundle.url(forResource: "ContentManifest", withExtension: "json") else {
            return ContentLibrary(ageGroups: [], categories: [], pages: [])
        }

        do {
            let data = try Data(contentsOf: url)
            let manifest = try JSONDecoder().decode(ContentManifest.self, from: data)
            return ContentLibrary(
                ageGroups: manifest.ageGroups,
                categories: manifest.categories,
                pages: manifest.pages
            )
        } catch {
            assertionFailure("Could not load ContentManifest.json: \(error)")
            return ContentLibrary(ageGroups: [], categories: [], pages: [])
        }
    }
}

enum CategoryPreferences {
    static let disabledCategoryIDsKey = "disabledCategoryIDs"
    static let disabledAgeGroupIDsKey = "disabledAgeGroupIDs"

    static func decode(_ rawValue: String) -> Set<String> {
        Set(rawValue.split(separator: ",").map(String.init))
    }

    static func encode(_ categoryIDs: Set<String>) -> String {
        categoryIDs.sorted().joined(separator: ",")
    }
}
