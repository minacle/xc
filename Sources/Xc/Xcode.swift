import Foundation
import AppKit

public struct Xcode {

    public var name: String
    public var version: Version
    public var build: Build
    public var fullPath: String

    public init(name: String, version: Version? = nil) {
        self.name = name
        self.fullPath = NSWorkspace.shared.fullPath(forApplication: name)!
        let versionPList = (try? PropertyListSerialization.propertyList(from: Data(contentsOf: URL(fileURLWithPath: "\(self.fullPath)/Contents/version.plist")), format: nil) as? [String: Any]) ?? [:]
        if let version = version {
            self.version = version
        }
        else {
            self.version = .init(string: versionPList["CFBundleShortVersionString"] as? String ?? "")
        }
        self.build = .init(string: versionPList["ProductBuildVersion"] as? String ?? "")
    }
}

