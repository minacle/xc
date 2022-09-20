import Foundation
import XcKit

private let defaultFileManager: FileManager = .default

extension Xcode {

    var url: URL {
        .init(fileURLWithPath: path, isDirectory: true)
    }

    var contentsDirectoryURL: URL {
        url.appendingPathComponent("Contents", isDirectory: true)
    }

    var developerDirectoryURL: URL {
        contentsDirectoryURL
        .appendingPathComponent("Developer", isDirectory: true)
    }

    var applicationsDirectoryURL: URL {
        developerDirectoryURL
        .appendingPathComponent("Applications", isDirectory: true)
    }

    var toolchainsDirectoryURL: URL {
        developerDirectoryURL
        .appendingPathComponent("Toolchains", isDirectory: true)
    }

    var usrDirectoryURL: URL {
        developerDirectoryURL
        .appendingPathComponent("usr", isDirectory: true)
    }

    var binDirectoryURL: URL {
        usrDirectoryURL
        .appendingPathComponent("bin", isDirectory: true)
    }

    var applicationURLs: [URL] {
        guard
            let applicationsDirectoryURLResourceValues =
                applicationsDirectoryURL.resourceValues(
                    forKeys: [.isDirectoryKey, .isExecutableKey]),
            applicationsDirectoryURLResourceValues.isDirectory == true,
            applicationsDirectoryURLResourceValues.isExecutable == true
        else {
            return .init()
        }
        return
            try! defaultFileManager
            .contentsOfDirectory(
                at: applicationsDirectoryURL,
                includingPropertiesForKeys: nil)
            .filter({$0.pathExtension == "app"})
    }

    var toolchainURLs: [URL] {
        guard
            let toolchainsDirectoryURLResourceValues =
                toolchainsDirectoryURL.resourceValues(
                    forKeys: [.isDirectoryKey, .isExecutableKey]),
            toolchainsDirectoryURLResourceValues.isDirectory == true,
            toolchainsDirectoryURLResourceValues.isExecutable == true
        else {
            return .init()
        }
        return
            try! defaultFileManager
            .contentsOfDirectory(
                at: toolchainsDirectoryURL,
                includingPropertiesForKeys: nil)
            .filter({$0.pathExtension == "xctoolchain"})
    }

    var binURLs: [URL] {
        guard
            let binDirectoryURLResourceValues =
                binDirectoryURL.resourceValues(
                    forKeys: [.isDirectoryKey, .isExecutableKey]),
            binDirectoryURLResourceValues.isDirectory == true,
            binDirectoryURLResourceValues.isExecutable == true
        else {
            return .init()
        }
        return
            try! defaultFileManager
            .contentsOfDirectory(
                at: binDirectoryURL,
                includingPropertiesForKeys: nil)
    }

    func usrDirectoryURL(forToolchainURL toolchainURL: URL) -> URL {
        toolchainURL
        .appendingPathComponent("usr", isDirectory: true)
    }

    func binDirectoryURL(forToolchainURL toolchainURL: URL) -> URL {
        usrDirectoryURL(forToolchainURL: toolchainURL)
        .appendingPathComponent("bin", isDirectory: true)
    }

    func binURLs(forToolchainURL toolchainURL: URL) -> [URL] {
        let binDirectoryURL =
            binDirectoryURL(forToolchainURL: toolchainURL)
        guard
            let binDirectoryURLResourceValues =
                binDirectoryURL
                .resourceValues(
                    forKeys: [.isDirectoryKey, .isExecutableKey]),
            binDirectoryURLResourceValues.isDirectory == true,
            binDirectoryURLResourceValues.isExecutable == true
        else {
            return .init()
        }
        return
            try! defaultFileManager
            .contentsOfDirectory(
                at: binDirectoryURL,
                includingPropertiesForKeys: nil)
    }
}

extension Xcode {

    var defaultToolchainURL: URL {
        toolchainsDirectoryURL
        .appendingPathComponent("XcodeDefault.xctoolchain", isDirectory: true)
    }
}
