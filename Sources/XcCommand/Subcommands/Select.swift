import ArgumentParser
import Foundation
import XcKit

extension XcCommand {

    struct Select: ParsableCommand {

        @OptionGroup
        var licenseTypesOptions: LicenseTypesOptions

        @OptionGroup
        var specifierOptions: SpecifierOptions

        @Flag(
            name: [.short, .long])
        var printPath: Bool = false

        @Flag(
            name: [.customShort("R"), .long])
        var reset: Bool = false

        // MARK: ParsableCommand

        func run() throws {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: Self.link) {
                do {
                    try fileManager.removeItem(atPath: Self.link)
                }
                catch(let error as NSError) {
                    switch error.domain {
                    case NSCocoaErrorDomain:
                        switch error.code {
                        case NSFileWriteNoPermissionError:
                            throw Error.noPermission
                        default:
                            throw error
                        }
                    default:
                        throw error
                    }
                }
            }
            if reset {
                return
            }
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
            do {
                try fileManager.createSymbolicLink(atPath: Self.link, withDestinationPath: "\(xcode.path)/Contents/Developer")
            }
            catch(let error as NSError) {
                switch error.domain {
                case NSCocoaErrorDomain:
                    switch error.code {
                    case NSFileWriteNoPermissionError:
                        throw Error.noPermission
                    default:
                        throw error
                    }
                default:
                    throw error
                }
            }
        }

        func validate() throws {
            if printPath {
                print(Self.path)
                throw ExitCode.success
            }
        }
    }
}

extension XcCommand.Select {

    enum Error: Swift.Error {

        case noXcodeAppFound
        case noSpecifiedXcodeAppFound
        case noPermission
    }

    static let link: String = "/var/db/xcode_select_link"

    static var path: String {
        let path = (link as NSString).resolvingSymlinksInPath
        guard path != link
        else {
            return "/Library/Developer/CommandLineTools"
        }
        return path
    }

    // MARK: ParsableCommand

    static let configuration: CommandConfiguration =
        .init(
            abstract: "Behave as like as xcode-select(1).")
}
