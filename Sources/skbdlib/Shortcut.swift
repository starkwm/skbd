import Carbon
import Foundation

public typealias HandlerFunc = () throws -> Void

public struct Shortcut {
  public static func handler(for command: String) -> HandlerFunc {
    let shell = ProcessInfo.processInfo.environment["SHELL"].flatMap { $0.isEmpty ? nil : $0 } ?? "/bin/bash"

    let handler: HandlerFunc = {
      if command.isEmpty {
        return
      }

      try Process.run(URL(fileURLWithPath: shell), arguments: ["-c", command])
    }

    return handler
  }

  public let identifier = UUID()

  public var isLeader: Bool = false

  public var keyCode: UInt32?
  public var modifierFlags: UInt32?

  public var handler: HandlerFunc!

  public init() {}

  public init(_ keyCode: UInt32, _ modifierFlags: UInt32) {
    self.keyCode = keyCode
    self.modifierFlags = modifierFlags
  }

  public init(_ keyCode: UInt32, _ modifierFlags: UInt32, _ handler: @escaping HandlerFunc) {
    self.keyCode = keyCode
    self.modifierFlags = modifierFlags
    self.handler = handler
  }
}
