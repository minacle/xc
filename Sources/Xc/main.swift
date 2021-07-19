import ArgumentParser
import Foundation
import XcKit

enum XcError: String, Error {

    case noXcodeAppFound =
        "No Xcode app found."
    case cannotParseSpecifier =
        "Cannot parse specifier."
    case noSpecifiedXcodeAppFound =
        "No specified Xcode app found."
    case operationNotImplemented =
        "Operation not implemented."
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

    enum Specifier {

        enum Operator: String, CaseIterable {

            case equalTo = "=="
            case greaterThanOrEqualTo = ">="
            case approximatelyGreaterThanOrEqualTo = "~>"
            case greaterThan = ">"
            case lessThan = "<"
            case lessThanOrEqualTo = "<="
        }

        case `nil`
        case error(XcError)
        case build(Xcode.Build)
        case version(Xcode.Version)
        case operatorAndBuild(Operator, Xcode.Build)
        case operatorAndVersion(Operator, Xcode.Version)

        init(expressionString string: String) {
            var string = string
            var `operator`: Operator?
            for _operator in Operator.allCases.sorted(by: {$0.rawValue.count > $1.rawValue.count}) {
                let rawValue = _operator.rawValue
                if string.hasPrefix(rawValue) {
                    `operator` = _operator
                    string.removeFirst(rawValue.count)
                    break
                }
            }
            if let build = Xcode.Build(string: string) {
                if let `operator` = `operator` {
                    self = .operatorAndBuild(`operator`, build)
                }
                else {
                    self = .build(build)
                }
            }
            else if let version = Xcode.Version(string: string) {
                if let `operator` = `operator` {
                    self = .operatorAndVersion(`operator`, version)
                }
                else {
                    self = .version(version)
                }
            }
            else {
                self = .error(.cannotParseSpecifier)
            }
        }
    }

    @Flag(
        exclusivity: .exclusive,
        help: "Allow or disallow beta version.")
    var flag: Flags = .releaseOnly

    @Flag(
        name: [.customShort("l"), .customLong("list")],
        help: "List every found Xcode apps.")
    var showList = false

    @Option(
        name: [.customShort("s"), .customLong("specify")],
        parsing: .unconditional,
        help: .init(
            "Specify the build or version of Xcode to run.",
            discussion: """
                        To specify build 11E801a (for Xcode 11.7 GM), send "11E801a".
                        To specify version 12.0.1 (for Xcode 12A7300 GM), send "12.0.1".
                        To specify most recent version starts with 11, send "~>11.0".
                        To specify most recent version starts with 8.3, send "~>8.3.0".
                        """,
            valueName: "specifier"),
        transform: Specifier.init(expressionString:))
    var specifier: Specifier = .nil

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
        var xcodes: [Xcode] =
            xc.xcodes
            .filter({self.flag == .releaseOnly ? $0.licenseType == .gm : true})
        switch self.specifier {
        case .nil:
            if !self.showList {
                xcodes.sort(by: {$0.version == $1.version ? $0.build == $1.build ? $0.licenseType > $1.licenseType : $0.build > $1.build : $0.version > $1.version})
            }
        case .error(let error):
            throw error
        case .build(let build):
            xcodes = xcodes.filter({$0.build == build})
            if !self.showList {
                xcodes.sort(by: {$0.build == $1.build ? $0.licenseType > $1.licenseType : $0.build > $1.build})
            }
        case .version(let version):
            xcodes = xcodes.filter({$0.version == version})
            if !self.showList {
                xcodes.sort(by: {$0.version == $1.version ? $0.build == $1.build ? $0.licenseType > $1.licenseType : $0.build > $1.build : $0.version > $1.version})
            }
        case .operatorAndBuild(let `operator`, let build):
            // `~>` operator for Version.Build is not implemented yet
            guard `operator` != .approximatelyGreaterThanOrEqualTo
            else {
                throw XcError.operationNotImplemented
            }
            xcodes = xcodes.filter {
                switch `operator` {
                case .equalTo:
                    return $0.build == build
                case .greaterThanOrEqualTo:
                    return $0.build >= build
                case .approximatelyGreaterThanOrEqualTo:
                    // not implemented
                    return false
                case .greaterThan:
                    return $0.build > build
                case .lessThan:
                    return $0.build < build
                case .lessThanOrEqualTo:
                    return $0.build <= build
                }
            }
            if !self.showList {
                xcodes.sort(by: {$0.build == $1.build ? $0.licenseType > $1.licenseType : $0.build > $1.build})
            }
        case .operatorAndVersion(let `operator`, let version):
            xcodes = xcodes.filter {
                switch `operator` {
                case .equalTo:
                    return $0.version == version
                case .greaterThanOrEqualTo:
                    return $0.version >= version
                case .approximatelyGreaterThanOrEqualTo:
                    return $0.version ~> version
                case .greaterThan:
                    return $0.version > version
                case .lessThan:
                    return $0.version < version
                case .lessThanOrEqualTo:
                    return $0.version <= version
                }
            }
            if !self.showList {
                xcodes.sort(by: {$0.version == $1.version ? $0.build == $1.build ? $0.licenseType > $1.licenseType : $0.build > $1.build : $0.version > $1.version})
            }
        }
        if self.showList {
            for xcode in xcodes.sorted(by: {$0.version == $1.version ? $0.build == $1.build ? $0.licenseType > $1.licenseType : $0.build > $1.build : $0.version > $1.version}) {
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
        guard !xcodes.isEmpty
        else {
            if case .nil = self.specifier {
                throw XcError.noXcodeAppFound
            }
            throw XcError.noSpecifiedXcodeAppFound
        }
        let xcode = xcodes[0]
        var arguments = ["-a", xcode.path]
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
