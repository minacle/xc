import ArgumentParser
import XcKit

extension XcCommand {

    struct Print: AsyncParsableCommand {

        @OptionGroup
        var licenseTypesOptions: LicenseTypesOptions

        @OptionGroup
        var specifierOptions: SpecifierOptions

        @OptionGroup
        var formatOptions: FormatOptions

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
            guard let xcode = xcodes.filter(licenseTypes: licenseTypes).filter(specifier: specifier).sorted(specifier: specifier).first
            else {
                throw Error.noSpecifiedXcodeAppFound
            }
            print(try formatOptions.format(xcode: xcode))
        }
    }
}

extension XcCommand.Print {

    enum Error: Swift.Error {

        case noXcodeAppFound
        case noSpecifiedXcodeAppFound
        case invalidFormatSequence(String)
        case invalidEscapeSequence(String)
        case invalidUnicodeScalar(UInt32)
    }

    struct FormatOptions: ParsableArguments {

        @Option(
            name: [.customShort("f"), .customLong("format")],
            parsing: .unconditional,
            help: .init(
                "Set the output format.",
                discussion: """
                            %b stands for build.
                            %l stands for license type (Release, Beta or Unknown).
                            %n stands for name.
                            %p stands for path.
                            %v stands for version.
                            %% stands for percent sign (%) itself.
                            Escapings are supported: see Special Characters in String Literals section on Swift Language Guide.
                            """,
                valueName: "format"))
        private var _format: String?

        var format: String {
            get {
                _format ?? "%p"
            }
            set {
                _format = newValue
            }
        }

        func format(xcode: Xcode) throws -> String {
            var format = self.format[...]
            var result = ""
            while !format.isEmpty {
                if format.hasPrefix("%") {
                    switch format[format.index(after: format.startIndex)] {
                    case "%":
                        result += "%"
                    case "b":
                        result += "\(xcode.build)"
                    case "l":
                        switch xcode.licenseType {
                        case .gm:
                            result += "Release"
                        case .beta:
                            result += "Beta"
                        case .unknown:
                            result += "Unknown"
                        }
                    case "n":
                        result += "\(xcode.name)"
                    case "p":
                        result += "\(xcode.path)"
                    case "v":
                        result += "\(xcode.version)"
                    case "L":
                        switch xcode.licenseType {
                        case .unknown:
                            result += "Unknown"
                        default:
                            result += "\(xcode.licenseType)"
                        }
                    default:
                        throw Error.invalidFormatSequence(.init(format[...format.index(after: format.startIndex)]))
                    }
                    format = format[format.index(format.startIndex, offsetBy: 2)...]
                }
                else if format.hasPrefix("\\") {
                    switch format[format.index(after: format.startIndex)] {
                    case "\"":
                        result += "\""
                    case "'":
                        result += "'"
                    case "0":
                        result += "\0"
                    case "r":
                        result += "\r"
                    case "n":
                        result += "\n"
                    case "t":
                        result += "\t"
                    case "u":
                        guard
                            let openingIndex = format.firstIndex(of: "{"),
                            openingIndex == format.index(format.startIndex, offsetBy: 2),
                            let closingIndex = format[openingIndex...].firstIndex(of: "}")
                        else {
                            throw Error.invalidEscapeSequence(.init(format[...format.index(after: format.startIndex)]))
                        }
                        guard let value = UInt32(format[format.index(after: openingIndex) ..< closingIndex], radix: 16)
                        else {
                            throw Error.invalidEscapeSequence(.init(format[...closingIndex]))
                        }
                        guard
                            let unicodeScalar = UnicodeScalar(value)
                        else {
                            throw Error.invalidUnicodeScalar(value)
                        }
                        result.append(Character(unicodeScalar))
                        format = format[format.index(after: closingIndex)...]
                        continue
                    case "\\":
                        result += "\\"
                    default:
                        throw Error.invalidEscapeSequence(.init(format[...format.index(after: format.startIndex)]))
                    }
                    format = format[format.index(format.startIndex, offsetBy: 2)...]
                }
                else {
                    result.append(format.removeFirst())
                }
            }
            return result
        }
    }

    // MARK: ParsableCommand

    static let configuration: CommandConfiguration =
        .init(
            abstract: "Print information of specified Xcode app on the machine.")
}
