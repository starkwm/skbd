import Carbon
import Foundation

public struct Shortcut {
  public static func handler(for command: String) -> (() -> Void) {
    let shell = ProcessInfo.processInfo.environment["SHELL"].flatMap { $0.isEmpty ? nil : $0 } ?? "/bin/bash"

    let handler: (() -> Void) = {
      let process = Process()
      process.executableURL = URL(fileURLWithPath: shell)
      process.arguments = ["-c", command]
      try? process.run()
    }

    return handler
  }

  public let identifier = UUID()

  public var keyCode: UInt32?
  public var modifierFlags: UInt32?

  public var handler: (() -> Void)!

  public init() {}

  public init(_ keyCode: UInt32, _ modifierFlags: UInt32) {
    self.keyCode = keyCode
    self.modifierFlags = modifierFlags
  }

  public init(_ keyCode: UInt32, _ modifierFlags: UInt32, _ handler: @escaping (() -> Void)) {
    self.keyCode = keyCode
    self.modifierFlags = modifierFlags
    self.handler = handler
  }
}
