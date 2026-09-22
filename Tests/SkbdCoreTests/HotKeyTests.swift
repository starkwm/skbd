import Carbon
import Foundation
import Testing

@testable import SkbdCore

@Suite("HotKey")
struct HotKeyTests {
  @Test("Read a key event")
  func fromEvent() {
    let event = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(kVK_Return), keyDown: true)!
    event.flags = [.maskCommand, .maskShift]

    let hotKey = HotKey.from(event: event)

    #expect(hotKey.modifierFlags == [.cmd, .shift])
    #expect(hotKey.key == kVK_Return)
  }

  @Test("A missing command passes the event through")
  func noCommand() {
    let hotKey = HotKey(modifierFlags: .cmd, key: 0)

    #expect(hotKey.execute() == .passthrough)
  }

  @Test("Run the command and return the event policy", arguments: [false, true])
  func execute(passthrough: Bool) async throws {
    let file = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: file) }

    let hotKey = HotKey(
      modifierFlags: .cmd,
      key: 0,
      command: "echo skbd > '\(file.path)'",
      passthrough: passthrough
    )

    let result = hotKey.execute()
    let deadline = ContinuousClock.now.advanced(by: .seconds(5))

    while (try? String(contentsOf: file, encoding: .utf8)) != "skbd\n"
      && ContinuousClock.now < deadline
    {
      try await Task.sleep(for: .milliseconds(10))
    }

    #expect(try String(contentsOf: file, encoding: .utf8) == "skbd\n")
    #expect(result == (passthrough ? .passthrough : .consumed))
  }

  @Test("Match keys and modifiers")
  func matches() {
    let binding = HotKey(modifierFlags: .cmd, key: 0)

    #expect(binding.matches(HotKey(modifierFlags: .cmd, key: 0)))
    #expect(binding.matches(HotKey(modifierFlags: .lcmd, key: 0)))
    #expect(!binding.matches(HotKey(modifierFlags: .cmd, key: 1)))
    #expect(!binding.matches(HotKey(modifierFlags: .alt, key: 0)))
  }

  @Test("Describe a shortcut")
  func description() {
    let hotKey = HotKey(modifierFlags: [.cmd, .shift], key: UInt32(kVK_Return))

    #expect(hotKey.description == "<HotKey flags: <ModifierFlags cmd|shift>, key: return>")
  }
}
