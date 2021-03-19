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
