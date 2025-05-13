import Foundation

public typealias Action = () throws -> Void

protocol Shortcut {
  var action: Action? { get }
}

extension Shortcut {
  static func action(for command: String) -> Action {
    let shell = ProcessInfo.processInfo.environment["SHELL"].flatMap { $0.isEmpty ? nil : $0 } ?? "/bin/bash"

    let action: Action = {
      if command.isEmpty {
        return
      }

      try Process.run(URL(fileURLWithPath: shell), arguments: ["-c", command])
    }

    return action
  }
}
