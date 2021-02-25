import Foundation

private struct StandardErrorStream: TextOutputStream {

    fileprivate func write(_ string: String) {
        fputs(string, stderr)
    }
}

private let xc = Xc.default

guard !xc.xcodes.isEmpty
else {
    var standardError = StandardErrorStream()
    print("No Xcode app found.", to: &standardError)
    exit(1)
}

let xcodes = xc.xcodes.sorted(by: {$0.version == $1.version ? $0.build == $1.build ? $0.licenseType > $1.licenseType : $0.build > $1.build : $0.version > $1.version})

// FIXME: arguments may be abused.
private var arguments = ["-a", xcodes[0].path]
arguments.append(contentsOf: CommandLine.arguments[1...])

Process.launchedProcess(launchPath: "/usr/bin/open", arguments: arguments)
