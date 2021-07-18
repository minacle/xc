import Foundation

extension Xcode {

    public struct Build {

        public var major: UInt
        public var minor: Minor
        public var patch: UInt
        public var revision: Revision?

        public init(major: UInt = 1, minor: Minor = .a, patch: UInt = 1, revision: Revision? = nil) {
            self.major = major
            self.minor = minor
            self.patch = patch
            self.revision = revision
        }

        public init(_ major: UInt, _ minor: Minor = .a, _ patch: UInt = 1, _ revision: Revision? = nil) {
            self.major = major
            self.minor = minor
            self.patch = patch
            self.revision = revision
        }

        private static let _regex =
            try! NSRegularExpression(pattern: "^([1-9][0-9]*)([A-Z])([1-9][0-9]*)([a-z])?$")

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
                    self.minor = Minor(rawValue: nsString.substring(with: range).first!)!
                }
                else {
                    return nil
                }
                range = match.range(at: 3)
                if range.location != NSNotFound {
                    self.patch = UInt(nsString.substring(with: range))!
                }
                else {
                    return nil
                }
                range = match.range(at: 4)
                if range.location != NSNotFound {
                    self.revision = Revision(rawValue: nsString.substring(with: range).first!)!
                }
            }
            else {
                return nil
            }
        }
    }
}

extension Xcode.Build: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return
            lhs.major == rhs.major &&
            lhs.minor == rhs.minor &&
            lhs.patch == rhs.patch &&
            lhs.revision == rhs.revision
    }

    public static func !=(lhs: Self, rhs: Self) -> Bool {
        return
            lhs.major != rhs.major ||
            lhs.minor != rhs.minor ||
            lhs.patch != rhs.patch ||
            lhs.revision != rhs.revision
    }
}

extension Xcode.Build: Comparable {

    public static func <(lhs: Self, rhs: Self) -> Bool {
        if lhs.major == rhs.major {
            if lhs.minor == rhs.minor {
                if lhs.patch == rhs.patch {
                    return lhs.revision < rhs.revision
                }
                return lhs.patch < rhs.patch
            }
            return lhs.minor < rhs.minor
        }
        return lhs.major < rhs.major
    }

    public static func >(lhs: Self, rhs: Self) -> Bool {
        if lhs.major == rhs.major {
            if lhs.minor == rhs.minor {
                if lhs.patch == rhs.patch {
                    return lhs.revision > rhs.revision
                }
                return lhs.patch > rhs.patch
            }
            return lhs.minor > rhs.minor
        }
        return lhs.major > rhs.major
    }
}

extension Xcode.Build: CustomStringConvertible {

    public var description: String {
        if let revision = self.revision {
            return "\(self.major)\(self.minor.rawValue)\(self.patch)\(revision.rawValue)"
        }
        else {
            return "\(self.major)\(self.minor.rawValue)\(self.patch)"
        }
    }
}

extension Xcode.Build: CustomDebugStringConvertible {

    public var debugDescription: String {
        return self.description
    }
}

extension Xcode.Build {

    public enum Minor: Character {

        case a = "A"
        case b = "B"
        case c = "C"
        case d = "D"
        case e = "E"
        case f = "F"
        case g = "G"
        case h = "H"
        case i = "I"
        case j = "J"
        case k = "K"
        case l = "L"
        case m = "M"
        case n = "N"
        case o = "O"
        case p = "P"
        case q = "Q"
        case r = "R"
        case s = "S"
        case t = "T"
        case u = "U"
        case v = "V"
        case w = "W"
        case x = "X"
        case y = "Y"
        case z = "Z"
    }
}

extension Xcode.Build.Minor: CaseIterable {
}

extension Xcode.Build.Minor: Comparable {

    public static func <(lhs: Self, rhs: Self) -> Bool {
        return Self.allCases.firstIndex(of: lhs)! < Self.allCases.firstIndex(of: rhs)!
    }
}

extension Xcode.Build {

    public enum Revision: Character {

        case a = "a"
        case b = "b"
        case c = "c"
        case d = "d"
        case e = "e"
        case f = "f"
        case g = "g"
        case h = "h"
        case i = "i"
        case j = "j"
        case k = "k"
        case l = "l"
        case m = "m"
        case n = "n"
        case o = "o"
        case p = "p"
        case q = "q"
        case r = "r"
        case s = "s"
        case t = "t"
        case u = "u"
        case v = "v"
        case w = "w"
        case x = "x"
        case y = "y"
        case z = "z"
    }
}

extension Xcode.Build.Revision: CaseIterable {
}

extension Xcode.Build.Revision: Comparable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    public static func <(lhs: Self, rhs: Self) -> Bool {
        return Self.allCases.firstIndex(of: lhs)! < Self.allCases.firstIndex(of: rhs)!
    }

    public static func <(lhs: Self?, rhs: Self) -> Bool {
        guard let lhs = lhs
        else {
            return true
        }
        return lhs < rhs
    }

    public static func <(lhs: Self, rhs: Self?) -> Bool {
        guard let rhs = rhs
        else {
            return false
        }
        return lhs < rhs
    }

    public static func >(lhs: Self, rhs: Self) -> Bool {
        return Self.allCases.firstIndex(of: lhs)! < Self.allCases.firstIndex(of: rhs)!
    }

    public static func >(lhs: Self?, rhs: Self) -> Bool {
        guard let lhs = lhs
        else {
            return true
        }
        return lhs > rhs
    }

    public static func >(lhs: Self, rhs: Self?) -> Bool {
        guard let rhs = rhs
        else {
            return false
        }
        return lhs > rhs
    }
}

public func <(lhs: Xcode.Build.Revision?, rhs: Xcode.Build.Revision?) -> Bool {
    guard
        let lhs = lhs,
        let rhs = rhs
    else {
        return false
    }
    return lhs < rhs
}

public func <=(lhs: Xcode.Build.Revision?, rhs: Xcode.Build.Revision?) -> Bool {
    guard
        let lhs = lhs,
        let rhs = rhs
    else {
        return false
    }
    return lhs <= rhs
}

public func >(lhs: Xcode.Build.Revision?, rhs: Xcode.Build.Revision?) -> Bool {
    guard
        let lhs = lhs,
        let rhs = rhs
    else {
        return false
    }
    return lhs > rhs
}

public func >=(lhs: Xcode.Build.Revision?, rhs: Xcode.Build.Revision?) -> Bool {
    guard
        let lhs = lhs,
        let rhs = rhs
    else {
        return false
    }
    return lhs >= rhs
}
