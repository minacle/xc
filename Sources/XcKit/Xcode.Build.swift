import Foundation

extension Xcode {

    public struct Build {

        public var major: UInt {
            willSet {
                guard newValue > 0
                else {
                    self.major = 1
                    return
                }
            }
        }

        public var minor: Minor

        public var patch: UInt {
            willSet {
                guard newValue > 0
                else {
                    self.patch = 1
                    return
                }
            }
        }

        public var revision: Revision?

        public init(major: UInt = 1, minor: Minor = .a, patch: UInt = 1, revision: Revision? = nil) {
            self.major = max(major, 1)
            self.minor = minor
            self.patch = max(patch, 1)
            self.revision = revision
        }

        public init(_ major: UInt, _ minor: Minor = .a, _ patch: UInt = 1, _ revision: Revision? = nil) {
            self.major = max(major, 1)
            self.minor = minor
            self.patch = max(patch, 1)
            self.revision = revision
        }

        public init?(string: String) {
            if #available(macOS 13, *),
               let build = Self.init(engine: .swift, string: string)
            {
                self = build
            }
            else {
                self.init(engine: .foundation, string: string)
            }
        }
    }
}

@available(macOS, deprecated: 13)
extension Xcode.Build {

    private enum _Foundation {

        case foundation
    }

    private static let _nsRegex =
        try! NSRegularExpression(pattern: "^([1-9][0-9]*)([A-Z])([1-9][0-9]*)([a-z])?$")

    private init?(engine _: _Foundation, string: String) {
        let nsString = string as NSString
        if let match = Self._nsRegex.firstMatch(in: string, range: NSRange(location: 0, length: nsString.length)) {
            var range: NSRange
            range = match.range(at: 1)
            if range.location != NSNotFound {
                self.major = .init(nsString.substring(with: range))!
            }
            else {
                return nil
            }
            range = match.range(at: 2)
            if range.location != NSNotFound {
                self.minor = .init(nsString.substring(with: range))!
            }
            else {
                return nil
            }
            range = match.range(at: 3)
            if range.location != NSNotFound {
                self.patch = .init(nsString.substring(with: range))!
            }
            else {
                return nil
            }
            range = match.range(at: 4)
            if range.location != NSNotFound {
                self.revision = .init(nsString.substring(with: range))!
            }
        }
        else {
            return nil
        }
    }
}

@available(macOS, introduced: 13)
extension Xcode.Build {

    private enum _Swift {

        case swift
    }

#if canImport(_StringProcessing)
    private static let _regex =
        #/^(?<major>[1-9][0-9]*)(?<minor>[A-Z])(?<patch>[1-9][0-9]*)(?<revision>[a-z])?$/#
#endif

    private init?(engine _: _Swift, string: String) {
#if canImport(_StringProcessing)
        guard let match = try? Self._regex.firstMatch(in: string)
        else {
            return nil
        }
        self.major = .init(match.output.major)!
        self.minor = .init(match.output.minor)!
        self.patch = .init(match.output.patch)!
        if let revision = match.output.revision {
            self.revision = .init(revision)!
        }
#else
        return nil
#endif
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

extension Xcode.Build: CustomDebugStringConvertible {

    public var debugDescription: String {
        self.description
    }
}

extension Xcode.Build: CustomStringConvertible {

    public var description: String {
        if let revision = self.revision {
            return "\(self.major)\(self.minor)\(self.patch)\(revision)"
        }
        else {
            return "\(self.major)\(self.minor)\(self.patch)"
        }
    }
}

extension Xcode.Build: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.major == rhs.major &&
        lhs.minor == rhs.minor &&
        lhs.patch == rhs.patch &&
        lhs.revision == rhs.revision
    }

    public static func !=(lhs: Self, rhs: Self) -> Bool {
        lhs.major != rhs.major ||
        lhs.minor != rhs.minor ||
        lhs.patch != rhs.patch ||
        lhs.revision != rhs.revision
    }
}

extension Xcode.Build: Hashable {

    public func hash(into hasher: inout Hasher) {
        withUnsafeBytes(of: Self.self) {
            hasher.combine(bytes: $0)
        }
        hasher.combine(self.major)
        hasher.combine(self.minor)
        hasher.combine(self.patch)
        if let revision = self.revision {
            hasher.combine(revision)
        }
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

extension Xcode.Build.Minor {

    fileprivate init?<S>(_ rawValue: S)
    where S: StringProtocol {
        guard let rawValue = rawValue.first
        else {
            return nil
        }
        self.init(rawValue: rawValue)
    }
}

extension Xcode.Build.Minor: CaseIterable {
}

extension Xcode.Build.Minor: Comparable {

    public static func <(lhs: Self, rhs: Self) -> Bool {
        Self.allCases.firstIndex(of: lhs)! < Self.allCases.firstIndex(of: rhs)!
    }

    public static func >(lhs: Self, rhs: Self) -> Bool {
        Self.allCases.firstIndex(of: lhs)! > Self.allCases.firstIndex(of: rhs)!
    }
}

extension Xcode.Build.Minor: CustomStringConvertible {

    public var description: String {
        .init(describing: self.rawValue)
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

extension Xcode.Build.Revision {

    fileprivate init?<S>(_ rawValue: S)
    where S: StringProtocol {
        guard let rawValue = rawValue.first
        else {
            return nil
        }
        self.init(rawValue: rawValue)
    }
}

extension Xcode.Build.Revision: CaseIterable {
}

extension Xcode.Build.Revision: Comparable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    public static func <(lhs: Self, rhs: Self) -> Bool {
        Self.allCases.firstIndex(of: lhs)! < Self.allCases.firstIndex(of: rhs)!
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
        Self.allCases.firstIndex(of: lhs)! > Self.allCases.firstIndex(of: rhs)!
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

extension Xcode.Build.Revision: CustomStringConvertible {

    public var description: String {
        .init(describing: self.rawValue)
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
