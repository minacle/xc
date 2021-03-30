internal protocol _ApproximatelyComparable: Comparable {

    static func ~>(lhs: Self, rhs: Self) -> Bool
}
