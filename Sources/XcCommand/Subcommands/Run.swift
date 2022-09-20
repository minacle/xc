import AppKit
import ArgumentParser
import Foundation
import XcKit

extension XcCommand {

    struct Run: AsyncParsableCommand {

        @OptionGroup
        var licenseTypesOptions: LicenseTypesOptions

        @OptionGroup
        var specifierOptions: SpecifierOptions

        @Argument(
            help: "The command or App to execute.")
        var command: String

        @Argument(
            parsing: .unconditionalRemaining,
            help: "Arguments to send to the command or App.")
        var arguments: [String] = []

        // MARK: ParsableCommand

        func run() async throws {
            let xc = Xc()
            let xcodes = await xc.reload()
            guard !xcodes.isEmpty
            else {
                throw Error.noXcodeAppFound
            }
            let licenseTypes = licenseTypesOptions.licenseTypes
            let specifier = specifierOptions.specifier
            guard
                let xcode =
                    xcodes
                    .filter(licenseTypes: licenseTypes)
                    .filter(specifier: specifier)
                    .sorted(specifier: specifier)
                    .first
            else {
                throw Error.noSpecifiedXcodeAppFound
            }
            var commandRelativePathStack = [String]()
            var command = command
            while true {
                if command.hasPrefix("/") {
                    commandRelativePathStack = [""]
                    command.removeFirst(1)
                }
                else if command.hasPrefix("./") {
                    command.removeFirst(2)
                }
                else if command.hasPrefix("../") {
                    if commandRelativePathStack.count > 1 {
                        commandRelativePathStack.removeLast()
                    }
                    else if commandRelativePathStack.isEmpty {
                        commandRelativePathStack = [""]
                    }
                    command.removeFirst(3)
                }
                else if command.contains("*") {
                    throw Error.characterNotAllowed("*")
                }
                else if command.contains("?") {
                    throw Error.characterNotAllowed("?")
                }
                else {
                    break
                }
            }
            if let separatorIndex = command.lastIndex(of: "/") {
                command.removeSubrange(separatorIndex...)
            }
            let commandURL: URL?
            let applicationURL: URL?
        urlAssignment:
            if commandRelativePathStack.isEmpty {
                let commands = xcode.binURLs
                let applications = xcode.applicationURLs
                if
                    let url =
                        commands
                        .first(where: {$0.lastPathComponent == command})
                {
                    commandURL = url
                    applicationURL = nil
                }
                else if
                    let url =
                        applications
                        .first(where: {$0.lastPathComponent == command})
                {
                    commandURL = nil
                    applicationURL = url
                }
                else {
                    let commands =
                        xcode.binURLs(
                            forToolchainURL: xcode.defaultToolchainURL)
                    if
                        let url =
                            commands
                            .first(where: {$0.lastPathComponent == command})
                    {
                        commandURL = url
                        applicationURL = nil
                        break urlAssignment
                    }
                    throw Error.commandOrApplicationNotFound(self.command)
                }
            }
            else {
                commandRelativePathStack.removeFirst()
                commandURL =
                    xcode.developerDirectoryURL
                    .appendingPathComponent("\(commandRelativePathStack.joined(separator: "/"))/\(command)")
                applicationURL = nil
            }
            if let commandURL {
                guard
                    let commandURLResourceValues =
                        commandURL
                        .resourceValues(forKeys: [.isExecutableKey]),
                    commandURLResourceValues.isExecutable == true
                else {
                    throw Error.commandNotFound(self.command)
                }
                var terminationStatus = 0 as Int32
                try! await withCheckedThrowingContinuation {
                    (continuation) in
                    do {
                        try Process.run(commandURL, arguments: arguments) {
                            terminationStatus = $0.terminationStatus
                            continuation.resume()
                        }
                    }
                    catch {
                        continuation.resume(with: .failure(error))
                    }
                }
                throw ExitCode(terminationStatus)
            }
            else if let applicationURL {
                guard
                    let applicationURLResourceValues =
                        applicationURL
                        .resourceValues(forKeys: [.isApplicationKey]),
                    applicationURLResourceValues.isApplication == true
                else {
                    throw Error.commandOrApplicationNotFound(self.command)
                }
                let openConfiguration = NSWorkspace.OpenConfiguration()
                openConfiguration.arguments = arguments
                do {
                    _ = try await NSWorkspace.shared
                        .openApplication(
                            at: applicationURL,
                            configuration: openConfiguration)
                }
                catch {
                    throw ExitCode.failure
                }
            }
            else {
                fatalError()
            }
        }
    }
}

extension XcCommand.Run {

    enum Error: Swift.Error {

        case noXcodeAppFound
        case noSpecifiedXcodeAppFound
        case characterNotAllowed(Character)
        case commandNotFound(String)
        case commandOrApplicationNotFound(String)
    }

    // MARK: ParsableCommand

    static let configuration: CommandConfiguration =
        .init(
            abstract: "Run developer tool from the specified Xcode app.")
}
