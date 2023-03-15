import ArgumentParser
import Foundation

struct Arguments: ParsableArguments {
    @Option(name: .shortAndLong, help: ArgumentHelp("Path to the configuration file", valueName: "path"))
    var config: String = ("~/.config/skbd/skbdrc" as NSString).resolvingSymlinksInPath

    @Flag(name: .shortAndLong, help: "Reload the configuration file")
    var reload = false

    @Flag(name: .shortAndLong, help: "Show version information")
    var version = false
}

let arguments = Arguments.parseOrExit()
