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

    public static func <(lhs: Self, rhs: Self) -> Bool {
        switch lhs {
        case .unknown:
            return true
        case .gm:
            return false
        case .beta:
            return rhs == .gm
        }
    }

    public static func >(lhs: Self, rhs: Self) -> Bool {
        switch lhs {
        case .unknown:
            return false
        case .gm:
            return true
        case .beta:
            return rhs != .gm
        }
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

extension Xcode.LicenseType: Hashable {

    public func hash(into hasher: inout Hasher) {
        withUnsafeBytes(of: Self.self) {
            hasher.combine(bytes: $0)
        }
        hasher.combine(self.rawValue)
    }
}
