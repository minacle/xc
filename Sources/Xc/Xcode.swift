import Foundation

public struct Xcode {

    public var name: String
    public var path: String
    public var version: Version
    public var build: Build
    public var licenseType: LicenseType

    public init(name: String, path: String, version: Version? = nil) {
        self.name = name
        self.path = path
        let versionPList = (try? PropertyListSerialization.propertyList(from: Data(contentsOf: URL(fileURLWithPath: "\(self.path)/Contents/version.plist")), format: nil) as? [String: Any]) ?? [:]
        if let version = version {
            self.version = version
        }
        else {
            self.version = .init(string: versionPList["CFBundleShortVersionString"] as? String ?? "")
        }
        self.build = .init(string: versionPList["ProductBuildVersion"] as? String ?? "")
        let licenseInfoPList = (try? PropertyListSerialization.propertyList(from: Data(contentsOf: URL(fileURLWithPath: "\(self.path)/Contents/Resources/LicenseInfo.plist")), format: nil) as? [String: Any]) ?? [:]
        self.licenseType = .init(rawValue: licenseInfoPList["licenseType"] as? String ?? "")
    }
}

extension Xcode {

    public enum LicenseType: String, CaseIterable {

        case unknown = ""
        case gm = "GM"
        case beta = "Beta"

        public static let release = Self.gm

        public init(rawValue: String) {
            guard let licenseType = Self.allCases.first(where: {$0.rawValue == rawValue})
            else {
                self = .unknown
                return
            }
            self = licenseType
        }
    }
}

extension Xcode.LicenseType: Comparable {

    private static let _order: [Self] = [.gm, .beta, .unknown]

    public static func <(lhs: Self, rhs: Self) -> Bool {
        self._order.firstIndex(of: lhs)! < self._order.firstIndex(of: rhs)!
    }
}

extension Xcode.LicenseType: CustomStringConvertible {

    public var description: String {
        if case .unknown = self {
            return "(unknown)"
        }
        return self.rawValue
    }
}
