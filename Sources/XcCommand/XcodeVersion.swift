import Foundation

enum XcodeVersion {
}

extension XcodeVersion {

    static var string: String {
        get throws {
            let url: URL
            if #available(macOS 13, *) {
                url =
                    .init(
                        filePath: fileManager.currentDirectoryPath,
                        directoryHint: .isDirectory)
            }
            else {
                url =
                    .init(
                        fileURLWithPath: fileManager.currentDirectoryPath,
                        isDirectory: true)
            }
            return try string(for: url)
        }
    }

    private static let fileManager: FileManager = .default

    private static let xcodeVersionFileName: String = ".xcode-version"

    static func string(for url: URL) throws -> String {
        guard url.isFileURL
        else {
            return .init()
        }
        let url = url.standardizedFileURL
        var isDirectory = false as ObjCBool
        let path: String
        if #available(macOS 13, *) {
            path = url.path(percentEncoded: false)
        }
        else {
            path = url.path
        }
        guard
            fileManager.fileExists(
                atPath: path,
                isDirectory: &isDirectory),
            isDirectory.boolValue
        else {
            return .init()
        }
        let xcodeVersionURL = xcodeVersionURL(relativeTo: url)
        let xcodeVersionPath: String
        if #available(macOS 13, *) {
            xcodeVersionPath = xcodeVersionURL.path(percentEncoded: false)
        }
        else {
            xcodeVersionPath = xcodeVersionURL.path
        }
        guard
            fileManager.fileExists(
                atPath: xcodeVersionPath,
                isDirectory: &isDirectory),
            !isDirectory.boolValue
        else {
            let parentDirectoryURL =
                url
                .deletingLastPathComponent()
                .standardizedFileURL
            guard parentDirectoryURL != url
            else {
                return .init()
            }
            return try string(for: parentDirectoryURL)
        }
        var encoding = String.Encoding(rawValue: 0)
        do {
            return
                try
                    .init(
                        contentsOfFile: xcodeVersionPath,
                        usedEncoding: &encoding)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        catch CocoaError.fileReadNoPermission {
            return .init()
        }
    }

    private static func xcodeVersionURL(relativeTo url: URL? = nil) -> URL {
        if #available(macOS 13, *) {
            return
                (
                    url ??
                    .init(
                        filePath: fileManager.currentDirectoryPath,
                        directoryHint: .isDirectory)
                )
                .appending(
                    path: xcodeVersionFileName,
                    directoryHint: .notDirectory)
        }
        else {
            return
                (
                    url ??
                    .init(
                        fileURLWithPath: fileManager.currentDirectoryPath,
                        isDirectory: true)
                )
                .appendingPathComponent(
                    xcodeVersionFileName,
                    isDirectory: false)
        }
    }
}
