import ArgumentParser

@main
struct XcCommand: ParsableCommand {
}

extension XcCommand {

    // MARK: ParsableCommand

    static var configuration =
        CommandConfiguration(
            commandName: "xc",
            subcommands: [List.self, Open.self, Select.self],
            defaultSubcommand: Open.self)
}
