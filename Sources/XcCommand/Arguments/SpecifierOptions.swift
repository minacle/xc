import ArgumentParser

struct SpecifierOptions: ParsableArguments {

    @Option(
        name: [.customShort("s"), .customLong("specify")],
        parsing: .unconditional,
        help: .init(
            "Specify the build or version of Xcode to run.",
            discussion: """
                        To specify build 11E801a (for Xcode 11.7 GM), send "11E801a".
                        To specify version 12.0.1 (for Xcode 12A7300 GM), send "12.0.1".
                        To specify most recent version starts with 11, send "~>11.0".
                        To specify most recent version starts with 8.3, send "~>8.3.0".
                        """,
            valueName: "specifier"),
        transform: Specifier.init(expressionString:))
    private var _specifier: Specifier?

    var specifier: Specifier {
        get {
            _specifier ?? .nil
        }
        set {
            _specifier = newValue
        }
    }
}
