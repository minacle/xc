import Foundation

private let xc = Xc.default

guard !xc.xcodes.isEmpty
else {
    exit(1)
}

private var arguments = ["-a", xc.xcodes[0].fullPath]
arguments.append(contentsOf: CommandLine.arguments[1...])

Process.launchedProcess(launchPath: "/usr/bin/open", arguments: arguments)
