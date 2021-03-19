import ArgumentParser
import Foundation
import XcKit

enum XcError: String, Error {

    case noXcodeAppFound =
        "No Xcode app found."
}

extension XcError {

    var localizedDescription: String {
        return self.rawValue
    }
}

struct Main: ParsableCommand {

    enum Flags: EnumerableFlag {

        case allowBeta
        case releaseOnly
    }

    @Flag(
        exclusivity: .exclusive,
        help: "Allow or disallow beta version.")
    var flag: Flags = .releaseOnly

    @Flag(
        name: [.customShort("l"), .customLong("list")],
        help: "List every found Xcode apps.")
    var showList = false

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

    func run() throws {
        let xc = Xc.default
        guard !xc.xcodes.isEmpty
        else {
            throw XcError.noXcodeAppFound
        }
        let xcodes =
            xc.xcodes
            .filter({self.flag == .releaseOnly ? $0.licenseType == .gm : true})
            .sorted(by: {$0.version == $1.version ? $0.build == $1.build ? $0.licenseType > $1.licenseType : $0.build > $1.build : $0.version > $1.version})
        if self.showList {
            for xcode in xcodes {
                print(xcode.name)
                if case .gm = xcode.licenseType {
                    print("  Version \(xcode.version)", "(\(xcode.build))")
                }
                else {
                    print("  Version \(xcode.version)", xcode.licenseType, "(\(xcode.build))")
                }
                print("  Path: \(xcode.path)")
            }
            return
        }
        var arguments = ["-a", xcodes[0].path]
        arguments.append(contentsOf: self.paths)
        let fileHandleWithNullDevice = FileHandle.nullDevice
        let process = Process()
        process.arguments = arguments
        process.qualityOfService = .userInitiated
        process.standardInput = fileHandleWithNullDevice
        process.standardOutput = fileHandleWithNullDevice
        process.standardError = fileHandleWithNullDevice
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open", isDirectory: false)
        try process.run()
    }
}

extension Main {

    static var configuration =
        CommandConfiguration(
            commandName: "xc",
            abstract: "Run most recent version of Xcode app on the machine.")
}

extension Main.Flags {

    static func name(for value: Self) -> NameSpecification {
        switch value {
        case .allowBeta:
            return [
                .customShort("b"),
                .customLong("beta", withSingleDash: true),
                .long,
            ]
        case .releaseOnly:
            return [
                .customShort("r"),
                .customLong("gm", withSingleDash: true),
                .long,
            ]
        }
    }
}

Main.main()
