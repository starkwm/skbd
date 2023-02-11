import ArgumentParser
import Foundation

struct Arguments: ParsableArguments {
    @Flag(name: .shortAndLong, help: "Show version information")
    var version = false
}

let arguments = Arguments.parseOrExit()
