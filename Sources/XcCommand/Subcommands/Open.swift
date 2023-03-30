import AppKit
import ArgumentParser
import Dispatch
import Foundation
import XcKit

extension XcCommand {

    struct Open: AsyncParsableCommand {

        @OptionGroup
        var licenseTypesOptions: LicenseTypesOptions

        @OptionGroup
        var specifierOptions: SpecifierOptions

        @Flag(
            name: [.customShort("F"), .customLong("fresh")],
            help: "Launch the Xcode fresh, that is, without restoring windows.")
        var fresh: Bool = false

        @Flag(
            name: [.customShort("H"), .customLong("hide")],
            help: "Launch the Xcode hidden.")
        var hidden: Bool = false

        @Argument(
            parsing: .remaining,
            help: .init(
                "Path list to be opened.",
                discussion: """
                            Swift packages are can be selected by package root directory.
                            Open as workspace if .xcodeproj and/or .xcworkspace bundle selected.
                            Otherwise selected file will be opened as independent file.
                            """))
        var paths: [String] = []

        // MARK: ParsableCommand

        func run() async throws {
            let xc = Xc()
            let xcodes = await xc.reload()
            guard !xcodes.isEmpty
            else {
                throw Error.noXcodeAppFound
            }
            if fresh {
                let fileManager = FileManager.default
                let libraryURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
                let xcodeIdentifier = "com.apple.dt.Xcode"
                let savedStateURL = URL(fileURLWithPath: "Saved Application State/\(xcodeIdentifier).savedState", isDirectory: true, relativeTo: libraryURL)
                try? fileManager.removeItem(at: savedStateURL)
            }
            let licenseTypes = licenseTypesOptions.licenseTypes
            var specifier = specifierOptions.specifier
            if case .nil = specifier {
                let xcodeVersion = (try? XcodeVersion.string) ?? .init()
                if !xcodeVersion.isEmpty {
                    specifier = try .init(expressionString: xcodeVersion)
                }
            }
            guard let xcode = xcodes.filter(licenseTypes: licenseTypes).filter(specifier: specifier).sorted(specifier: specifier).first
            else {
                throw Error.noSpecifiedXcodeAppFound
            }
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.hides = hidden
            let workspace = NSWorkspace.shared
            let urls = paths.map({URL(fileURLWithPath: $0)})
            if urls.isEmpty {
                _ = try? await workspace.openApplication(at: xcode.url, configuration: configuration)
            }
            else {
                _ = try? await workspace.open(urls, withApplicationAt: xcode.url, configuration: configuration)
            }
        }
    }
}

extension XcCommand.Open {

    enum Error: Swift.Error {

        case noXcodeAppFound
        case noSpecifiedXcodeAppFound
    }

    // MARK: ParsableCommand

    static let configuration: CommandConfiguration =
        .init(
            abstract: "Open paths using most recent or specified version of Xcode app on the machine.")
}
