extension Xcode {

    public struct Version {

        public var major: UInt
        public var minor: UInt
        public var patch: UInt

        public init(major: UInt = .min, minor: UInt = .min, patch: UInt = .min) {
            self.major = major
            self.minor = minor
            self.patch = patch
        }

        public init(_ major: UInt, _ minor: UInt = .min, _ patch: UInt = .min) {
            self.major = major
            self.minor = minor
            self.patch = patch
        }

        public init(string: String) {
            let components = "\(string)..".components(separatedBy: ".")
            self.major = UInt(components[0]) ?? .min
            self.minor = UInt(components[1]) ?? .min
            self.patch = UInt(components[2]) ?? .min
        }
    }
}

extension Xcode.Version: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return
            lhs.major == rhs.major &&
            lhs.minor == rhs.minor &&
            lhs.patch == rhs.patch
    }
}

extension Xcode.Version: Comparable {

    public static func <(lhs: Self, rhs: Self) -> Bool {
        if lhs.major == rhs.major {
            if lhs.minor == rhs.minor {
                return lhs.patch < rhs.patch
            }
            return lhs.minor < rhs.minor
        }
        return lhs.major < rhs.major
    }

    public static func >(lhs: Self, rhs: Self) -> Bool {
        if lhs.major == rhs.major {
            if lhs.minor == rhs.minor {
                return lhs.patch > rhs.patch
            }
            return lhs.minor > rhs.minor
        }
        return lhs.major > rhs.major
    }
}

extension Xcode.Version: CustomStringConvertible {

    public var description: String {
        guard self.patch == 0
        else {
            return self.debugDescription
        }
        return "\(self.major).\(self.minor)"
    }
}

extension Xcode.Version: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "\(self.major).\(self.minor).\(self.patch)"
    }
}
