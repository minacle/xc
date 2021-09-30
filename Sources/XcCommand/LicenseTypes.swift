import XcKit

struct LicenseTypes: OptionSet {

    // MARK: OptionSet

    var rawValue: Int8
}

extension LicenseTypes {

    static let release: LicenseTypes = .init(rawValue: 1 << 0)
    static let beta: LicenseTypes = .init(rawValue: 1 << 1)

    static var all: LicenseTypes {
        [.release, .beta]
    }
}

extension Sequence
where Element == Xcode {

    func filter(licenseTypes: LicenseTypes) -> [Xcode] {
        let allowRelease = licenseTypes.contains(.release)
        let allowBeta = licenseTypes.contains(.beta)
        return filter({$0.licenseType == .release && allowRelease || $0.licenseType == .beta && allowBeta})
    }
}
