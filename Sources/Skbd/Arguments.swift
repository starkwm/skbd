import ArgumentParser
import Foundation

struct Arguments: ParsableArguments {
  @Option(
    name: .shortAndLong,
    help: ArgumentHelp("Path to a configuration file, or directory of configuration files", valueName: "path"),
    transform: URL.init(fileURLWithPath:)
  )
  var config: URL = FileManager.default.homeDirectoryForCurrentUser.appending(path: ".config/skbd")

  @Flag(name: .shortAndLong, help: "Reload the configuration file")
  var reload = false

  @Flag(name: .shortAndLong, help: "Show version information")
  var version = false
}

let arguments = Arguments.parseOrExit()
