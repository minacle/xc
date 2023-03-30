import Foundation
import XcKit

enum Specifier {

    case `nil`
    case build(Xcode.Build)
    case version(Xcode.Version)
    case operatorAndBuild(Operator, Xcode.Build)
    case operatorAndVersion(Operator, Xcode.Version)

    init(expressionString string: String) throws {
        var string = string.trimmingCharacters(in: .whitespaces)
        var `operator`: Operator?
        for _operator in Operator.allCases.sorted().reversed() {
            let rawValue = _operator.rawValue
            if string.hasPrefix(rawValue) {
                `operator` = _operator
                string.removeFirst(rawValue.count)
                string = string.trimmingCharacters(in: .whitespaces)
                break
            }
        }
        if let build = Xcode.Build(string: string) {
            if let `operator` = `operator` {
                self = .operatorAndBuild(`operator`, build)
            }
            else {
                self = .build(build)
            }
        }
        else if var version = Xcode.Version(string: string) {
            if let `operator` = `operator` {
                self = .operatorAndVersion(`operator`, version)
            }
            else {
                if version.patch == nil {
                    version.patch = 0
                }
                self = .version(version)
            }
        }
        else {
            throw Error.cannotParse(string)
        }
    }
}

extension Specifier {

    enum Error: Swift.Error {

        case cannotParse(String)
    }

    enum Operator: String, CaseIterable {

        case equalTo = "=="
        case greaterThanOrEqualTo = ">="
        case approximatelyGreaterThanOrEqualTo = "~>"
        case greaterThan = ">"
        case lessThan = "<"
        case lessThanOrEqualTo = "<="
    }
}

extension Specifier.Operator: Comparable, Equatable {

    // MARK: Comparable

    static func <(lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue.count < rhs.rawValue.count ? true : lhs.rawValue < rhs.rawValue
    }

    static func <=(lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue.count <= rhs.rawValue.count ? true : lhs.rawValue <= rhs.rawValue
    }

    static func >(lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue.count > rhs.rawValue.count ? true : lhs.rawValue > rhs.rawValue
    }

    static func >=(lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue.count >= rhs.rawValue.count ? true : lhs.rawValue >= rhs.rawValue
    }

    // MARK: Equatable

    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

extension Sequence
where Element == Xcode {

    func filter(specifier: Specifier) -> [Xcode] {
        switch specifier {
        case .nil:
            return .init(self)
        case .build(let build):
            return filter({$0.build == build})
        case .version(let version):
            return filter({$0.version == version})
        case .operatorAndBuild(let `operator`, let build):
            return filter {
                switch `operator` {
                case .equalTo:
                    return $0.build == build
                case .greaterThanOrEqualTo:
                    return $0.build >= build
                case .approximatelyGreaterThanOrEqualTo:
                    return $0.build.major == build.major && $0.build.minor == build.minor
                case .greaterThan:
                    return $0.build > build
                case .lessThan:
                    return $0.build < build
                case .lessThanOrEqualTo:
                    return $0.build <= build
                }
            }
        case .operatorAndVersion(let `operator`, let version):
            return filter {
                switch `operator` {
                case .equalTo:
                    return $0.version == version
                case .greaterThanOrEqualTo:
                    return $0.version >= version
                case .approximatelyGreaterThanOrEqualTo:
                    return $0.version ~> version
                case .greaterThan:
                    return $0.version > version
                case .lessThan:
                    return $0.version < version
                case .lessThanOrEqualTo:
                    return $0.version <= version
                }
            }
        }
    }

    func sorted(specifier: Specifier) -> [Xcode] {
        switch specifier {
        case .nil, .version(_), .operatorAndVersion(_, _):
            return sorted(by: _defaultSortingPredicate)
        case .build(_), .operatorAndBuild(_, _):
            return sorted(by: _buildSortingPredicate)
        }
    }
}

extension MutableCollection
where Self: RandomAccessCollection,
      Element == Xcode
{

    mutating func sort(specifier: Specifier) {
        switch specifier {
        case .nil, .version(_), .operatorAndVersion(_, _):
            sort(by: _defaultSortingPredicate)
        case .build(_), .operatorAndBuild(_, _):
            sort(by: _buildSortingPredicate)
        }
    }
}

private let _defaultSortingPredicate: (Xcode, Xcode) -> Bool = {
    if $0.version == $1.version {
        if $0.build == $1.build {
            return $0.licenseType > $1.licenseType
        }
        return $0.build > $1.build
    }
    return $0.version > $1.version
}

private let _buildSortingPredicate: (Xcode, Xcode) -> Bool = {
    if $0.build == $1.build {
        return $0.licenseType > $1.licenseType
    }
    return $0.build > $1.build
}
