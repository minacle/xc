import Foundation

public struct Xcode {

    public var name: String
    public var path: String
    public var version: Version
    public var build: Build
    public var licenseType: LicenseType

    public init?(name: String, path: String, version: Version? = nil) {
        self.name = name
        self.path = path
        let versionPList = (try? PropertyListSerialization.propertyList(from: Data(contentsOf: URL(fileURLWithPath: "\(self.path)/Contents/version.plist")), format: nil) as? [String: Any]) ?? [:]
        if var version = version {
            if version.patch == nil {
                version.patch = 0
            }
            self.version = version
        }
        else {
            return nil
        }
        if let build = Build(string: versionPList["ProductBuildVersion"] as? String ?? "") {
            self.build = build
        }
        else {
            return nil
        }
        let licenseInfoPList = (try? PropertyListSerialization.propertyList(from: Data(contentsOf: URL(fileURLWithPath: "\(self.path)/Contents/Resources/LicenseInfo.plist")), format: nil) as? [String: Any]) ?? [:]
        self.licenseType = .init(rawValue: licenseInfoPList["licenseType"] as? String ?? "")
    }
}

extension Xcode: Hashable {

    public func hash(into hasher: inout Hasher) {
        withUnsafeBytes(of: Self.self) {
            hasher.combine(bytes: $0)
        }
        hasher.combine(self.name)
        hasher.combine(self.path)
        hasher.combine(self.version)
        hasher.combine(self.build)
        hasher.combine(self.licenseType)
    }
}
