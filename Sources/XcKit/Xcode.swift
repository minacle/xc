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

extension Xcode: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.path)
    }
}
