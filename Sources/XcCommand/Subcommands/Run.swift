import AppKit
import ArgumentParser
import Foundation
import XcKit

extension XcCommand {

    struct Run: ParsableCommand {

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

        func run() throws {
            let xcodes = Xc.default.xcodes
            guard !xcodes.isEmpty
            else {
                throw Error.noXcodeAppFound
            }
            let licenseTypes = licenseTypesOptions.licenseTypes
            let specifier = specifierOptions.specifier
            guard let xcode = xcodes.filter(licenseTypes: licenseTypes).filter(specifier: specifier).sorted(specifier: specifier).first
            else {
                throw Error.noSpecifiedXcodeAppFound
            }
            let developerPath = "\(xcode.path)/Contents/Developer"
            let fileManager = FileManager.default
            let applications = try! fileManager.contentsOfDirectory(atPath: "\(developerPath)/Applications")
            let commands = try! fileManager.contentsOfDirectory(atPath: "\(developerPath)/usr/bin")
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
            if commandRelativePathStack.isEmpty {
                if commands.contains(command) {
                    command = "usr/bin/\(command)"
                }
                else if applications.contains(command) {
                    command = "Applications/\(command)"
                }
            }
            else {
                commandRelativePathStack.removeFirst()
                command = "\(commandRelativePathStack.joined(separator: "/"))/\(command)"
            }
            let commandURL = URL(fileURLWithPath: "\(developerPath)/\(command)")
            let commandURLResourceValues = try! commandURL.resourceValues(forKeys: [.isApplicationKey, .isExecutableKey])
            if commandURLResourceValues.isApplication == true {
                let dsema = DispatchSemaphore(value: 0)
                let openConfiguration = NSWorkspace.OpenConfiguration()
                openConfiguration.arguments = arguments
                NSWorkspace.shared.openApplication(at: commandURL, configuration: openConfiguration) {
                    (_, _) in
                    dsema.signal()
                }
                dsema.wait()
                throw ExitCode.success
            }
            else if commandURLResourceValues.isExecutable == true {
                var terminationStatus = 0
                let dsema = DispatchSemaphore(value: 0)
                do {
                    try Process.run(commandURL, arguments: arguments) {
                        process in
                        terminationStatus = .init(process.terminationStatus)
                        dsema.signal()
                    }
                }
                catch {
                    throw Error.commandNotFound(self.command)
                }
                dsema.wait()
                throw ExitCode(.init(terminationStatus))
            }
            throw Error.commandOrApplicationNotFound(self.command)
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
