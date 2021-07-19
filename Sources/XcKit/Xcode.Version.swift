import Foundation

extension Xcode {

    public struct Version {

        public var major: UInt
        public var minor: UInt
        public var patch: UInt?

        public init(major: UInt = .min, minor: UInt = .min, patch: UInt? = nil) {
            self.major = major
            self.minor = minor
            self.patch = patch
        }

        public init(_ major: UInt, _ minor: UInt = .min, _ patch: UInt? = nil) {
            self.major = major
            self.minor = minor
            self.patch = patch
        }

        private static let _regex =
            try! NSRegularExpression(pattern: "^(\\d+)\\.(\\d+)(?:\\.(\\d+))?$")

        public init?(string: String) {
            let nsString = string as NSString
            if let match = Self._regex.firstMatch(in: string, range: NSRange(location: 0, length: nsString.length)) {
                var range: NSRange
                range = match.range(at: 1)
                if range.location != NSNotFound {
                    self.major = UInt(nsString.substring(with: range))!
                }
                else {
                    return nil
                }
                range = match.range(at: 2)
                if range.location != NSNotFound {
                    self.minor = UInt(nsString.substring(with: range))!
                }
                else {
                    return nil
                }
                range = match.range(at: 3)
                if range.location != NSNotFound {
                    self.patch = UInt(nsString.substring(with: range))!
                }
            }
            else {
                return nil
            }
        }
    }
}

extension Xcode.Version {

    public static func ~>(lhs: Self, rhs: Self) -> Bool {
        guard lhs.major == rhs.major
        else {
            // 0.b ~> 1.y
            // 2.b ~> 1.y
            return false
        }
        if rhs.patch != nil {
            if lhs.patch != nil {
                if lhs.minor == rhs.minor {
                    // 1.1.c ~> 1.1.z
                    return lhs.patch.unsafelyUnwrapped >= rhs.patch.unsafelyUnwrapped
                }
                // 1.0.c ~> 1.1.z
                // 1.2.c ~> 1.1.z
                return false
            }
            // 1.b ~> 1.1.z
            return false
        }
        // 1.1.c ~> 1.1
        // 1.2.c ~> 1.1
        return lhs.minor >= rhs.minor
    }
}

extension Xcode.Version: Comparable {

    public static func <(lhs: Self, rhs: Self) -> Bool {
        if lhs.major == rhs.major {
            if lhs.minor == rhs.minor {
                return lhs.patch ?? .min < rhs.patch ?? .min
            }
            return lhs.minor < rhs.minor
        }
        return lhs.major < rhs.major
    }

    public static func >(lhs: Self, rhs: Self) -> Bool {
        if lhs.major == rhs.major {
            if lhs.minor == rhs.minor {
                return lhs.patch ?? .min > rhs.patch ?? .min
            }
            return lhs.minor > rhs.minor
        }
        return lhs.major > rhs.major
    }
}

extension Xcode.Version: CustomDebugStringConvertible {

    public var debugDescription: String {
        if let patch = self.patch {
            return "\(self.major).\(self.minor).\(patch)"
        }
        return "\(self.major).\(self.minor)"
    }
}

extension Xcode.Version: CustomStringConvertible {

    public var description: String {
        guard self.patch ?? 0 == 0
        else {
            return self.debugDescription
        }
        return "\(self.major).\(self.minor)"
    }
}

extension Xcode.Version: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.major == rhs.major &&
        lhs.minor == rhs.minor &&
        lhs.patch == rhs.patch
    }
}

extension Xcode.Version: Hashable {

    public func hash(into hasher: inout Hasher) {
        withUnsafeBytes(of: Self.self) {
            hasher.combine(bytes: $0)
        }
        hasher.combine(self.major)
        hasher.combine(self.minor)
        if let patch = self.patch {
            hasher.combine(patch)
        }
    }
}

extension Xcode.Version: _ApproximatelyComparable {
}
