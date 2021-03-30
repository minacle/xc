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

        public init(string: String) {
            let components = "\(string)..".components(separatedBy: ".")
            self.major = UInt(components[0]) ?? .min
            self.minor = UInt(components[1]) ?? .min
            if !components[2].isEmpty {
                self.patch = UInt(components[2]) ?? .min
            }
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
                // 1.b.c ~> 1.y.z
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

extension Xcode.Version: _ApproximatelyComparable {
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

extension Xcode.Version: CustomDebugStringConvertible {

    public var debugDescription: String {
        if let patch = self.patch {
            return "\(self.major).\(self.minor).\(patch)"
        }
        return "\(self.major).\(self.minor)"
    }
}
