import ArgumentParser

#if swift(>=5.6)
@main
struct XcCommand: AsyncParsableCommand {
}
#else
struct XcCommand: AsyncParsableCommand {
}
#endif

extension XcCommand {

    // MARK: ParsableCommand

    static var configuration =
        CommandConfiguration(
            commandName: "xc",
            subcommands: [List.self, Open.self, Print.self, Run.self],
            defaultSubcommand: Open.self)
}
