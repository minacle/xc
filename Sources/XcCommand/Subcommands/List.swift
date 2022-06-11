import ArgumentParser
import XcKit

extension XcCommand {

    struct List: AsyncParsableCommand {

        @OptionGroup
        var licenseTypesOptions: LicenseTypesOptions

        @OptionGroup
        var specifierOptions: SpecifierOptions

        // MARK: ParsableCommand

        func run() async throws {
            let xc = Xc()
            await xc.reload()
            let licenseTypes = licenseTypesOptions.licenseTypes
            let specifier = specifierOptions.specifier
            let xcodes = xc.xcodes.filter(licenseTypes: licenseTypes).filter(specifier: specifier).sorted(specifier: specifier)
            for xcode in xcodes {
                print(xcode.name)
                if case .gm = xcode.licenseType {
                    print("  Version \(xcode.version) (\(xcode.build))")
                }
                else {
                    print("  Version \(xcode.version) \(xcode.licenseType) (\(xcode.build))")
                }
                print("  Path: \(xcode.path)")
            }
        }
    }
}

extension XcCommand.List {

    // MARK: ParsableCommand

    static let configuration: CommandConfiguration =
        .init(
            abstract: "List every or specified version of Xcode app(s) on the machine.")
}
