import ArgumentParser

@main
struct XcCommand: AsyncParsableCommand {
}

extension XcCommand {

    // MARK: ParsableCommand

    static var configuration =
        CommandConfiguration(
            commandName: "xc",
            subcommands: [List.self, Open.self, Print.self, Run.self],
            defaultSubcommand: Open.self)
}
