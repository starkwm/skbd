import Carbon
import Foundation

public struct HotKey {
  // Commands launch on a serial queue so the event tap callback returns without waiting on
  // process creation, and commands still start in the order their shortcuts were pressed.
  private static let launchQueue = DispatchQueue(
    label: "skbd.command-launcher",
    qos: .userInitiated
  )

  static func from(event: CGEvent) -> HotKey {
    HotKey(
      modifierFlags: ModifierFlags.from(event.flags),
      key: UInt32(event.getIntegerValueField(.keyboardEventKeycode))
    )
  }

  var modifierFlags: ModifierFlags = []
  var key: UInt32 = 0
  var command: String?
  var passthrough: Bool = false

  init() {}

  init(
    modifierFlags: ModifierFlags,
    key: UInt32,
    command: String? = nil,
    passthrough: Bool = false
  ) {
    self.modifierFlags = modifierFlags
    self.key = key
    self.command = command
    self.passthrough = passthrough
  }

  func matches(_ event: HotKey) -> Bool {
    key == event.key && ModifierFlags.matches(modifierFlags, event.modifierFlags)
  }

  @discardableResult
  func execute() -> HotKeyResult {
    guard let command else { return .passthrough }

    Self.launchQueue.async {
      Self.launch(command)
    }

    return passthrough ? .passthrough : .consumed
  }

  private static func launch(_ command: String) {
    let shell =
      ProcessInfo.processInfo.environment["SHELL"].flatMap { $0.isEmpty ? nil : $0 } ?? "/bin/bash"

    let process = Process()
    process.executableURL = URL(fileURLWithPath: shell)
    process.arguments = ["-c", command]
    process.standardOutput = FileHandle.nullDevice
    process.standardError = FileHandle.nullDevice

    do {
      try process.run()
    } catch {
      fputs("error running command: \(error.localizedDescription)\n", stderr)
      fflush(stderr)
    }
  }
}

extension HotKey: CustomStringConvertible {
  public var description: String {
    "<HotKey flags: \(modifierFlags), key: \(KeyCodes.key(for: Int(key)))>"
  }
}

enum HotKeyResult {
  case passthrough
  case consumed
}
