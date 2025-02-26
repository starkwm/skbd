import Foundation

public typealias HandlerFunc = () throws -> Void

protocol Shortcut {}

extension Shortcut {
  static func handler(for command: String) -> HandlerFunc {
    let shell = ProcessInfo.processInfo.environment["SHELL"].flatMap { $0.isEmpty ? nil : $0 } ?? "/bin/bash"

    let handler: HandlerFunc = {
      if command.isEmpty {
        return
      }

      try Process.run(URL(fileURLWithPath: shell), arguments: ["-c", command])
    }

    return handler
  }
}
