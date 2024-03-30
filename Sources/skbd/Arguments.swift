import ArgumentParser
import Foundation

struct Arguments: ParsableArguments {
  @Option(name: .shortAndLong, help: ArgumentHelp("Path to the configuration file", valueName: "path"))
  var config: String = FileManager
    .default
    .homeDirectoryForCurrentUser
    .appending(path: ".config/skbd/skbdrc")
    .path()

  @Flag(name: .shortAndLong, help: "Reload the configuration file")
  var reload = false

  @Flag(name: .shortAndLong, help: "Show version information")
  var version = false
}

let arguments = Arguments.parseOrExit()
