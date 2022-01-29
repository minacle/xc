import ArgumentParser

@main
struct XcCommand: ParsableCommand {
}

extension XcCommand {

    // MARK: ParsableCommand

    static var configuration =
        CommandConfiguration(
            commandName: "xc",
            subcommands: [List.self, Open.self, Run.self],
            defaultSubcommand: Open.self)
}
