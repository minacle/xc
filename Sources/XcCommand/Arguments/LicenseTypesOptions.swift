import ArgumentParser

struct LicenseTypesOptions: ParsableArguments {

    @Flag(
        exclusivity: .exclusive,
        help: "Allow or disallow beta or release version.")
    private var _licenseTypes: LicenseTypes?

    var licenseTypes: LicenseTypes {
        get {
            _licenseTypes ?? .release
        }
        set {
            _licenseTypes = newValue
        }
    }
}

extension LicenseTypes: EnumerableFlag {

    // MARK: EnumerableFlag

    static var allCases: [LicenseTypes] {
        [.all, .beta, .release]
    }

    static func name(for value: LicenseTypes) -> NameSpecification {
        switch value {
        case .all:
            return [.customShort("a"), .customLong("all")]
        case .beta:
            return [.customShort("b"), .customLong("beta")]
        case .release:
            return [.customShort("r"), .customLong("release")]
        default:
            return []
        }
    }
}
