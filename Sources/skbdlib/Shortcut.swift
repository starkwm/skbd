import Foundation

public typealias Action = () throws -> Void

protocol Shortcut {}

extension Shortcut {
  static func handler(for command: String) -> Action {
    let shell = ProcessInfo.processInfo.environment["SHELL"].flatMap { $0.isEmpty ? nil : $0 } ?? "/bin/bash"

    let handler: Action = {
      if command.isEmpty {
        return
      }

      try Process.run(URL(fileURLWithPath: shell), arguments: ["-c", command])
    }

    return handler
  }
}
