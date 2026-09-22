import Carbon
import Darwin
import Foundation
import Testing

@testable import SkbdCore

@Suite("HotKeyTests")
struct HotKeyTests {
  @Test("from(event:): no modifiers")
  func fromEventWithNoModifiers() async throws {
    let event = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(0), keyDown: true)!
    event.flags = CGEventFlags()

    let hotKey = HotKey.from(event: event)

    #expect(hotKey.modifierFlags == [])
    #expect(hotKey.key == 0)
  }

  @Test("from(event:): cmd modifier")
  func fromEventWithCmdModifier() async throws {
    let event = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(0), keyDown: true)!
    event.flags = .maskCommand

    let hotKey = HotKey.from(event: event)

    #expect(hotKey.modifierFlags == .cmd)
    #expect(hotKey.key == 0)
  }

  @Test("from(event:): multiple modifiers")
  func fromEventWithMultipleModifiers() async throws {
    let event = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(0), keyDown: true)!
    event.flags = [.maskCommand, .maskShift]

    let hotKey = HotKey.from(event: event)

    #expect(hotKey.modifierFlags == [.cmd, .shift])
    #expect(hotKey.key == 0)
  }

  @Test("from(event:): special key")
  func fromEventWithSpecialKey() async throws {
    let event = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(36), keyDown: true)!
    event.flags = CGEventFlags()

    let hotKey = HotKey.from(event: event)

    #expect(hotKey.modifierFlags == [])
    #expect(hotKey.key == 36)
  }

  @Test("from(event:): invalid keycode")
  func fromEventWithInvalidKeycode() async throws {
    let event = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(999), keyDown: true)!
    event.flags = .maskCommand

    let hotKey = HotKey.from(event: event)

    #expect(hotKey.modifierFlags == .cmd)
    #expect(hotKey.key == 999)
  }

  @Test("execute(onExecute:): nil command")
  func executeWithNilCommand() async throws {
    let hotKey = HotKey(modifierFlags: .cmd, key: 0)
    var executed = false

    #expect(hotKey.command == nil)

    hotKey.execute(onExecute: { executed = true })

    #expect(executed == false)
  }

  @Test("execute(onExecute:): successful command")
  func executeWithSuccessfulCommand() async throws {
    let hotKey = HotKey(modifierFlags: .cmd, key: 0, command: "true")
    var executed = false

    hotKey.execute { executed = true }

    #expect(executed)
  }

  @Test("execute(onExecute:): failing command")
  func executeWithFailingCommand() async throws {
    let hotKey = HotKey(modifierFlags: .cmd, key: 0, command: "false")
    var executed = false

    hotKey.execute { executed = true }

    #expect(executed)
  }

  @Test("execute(onExecute:): SHELL unset falls back to /bin/bash")
  func executeFallsBackToBashWhenShellUnset() async throws {
    let originalShell = getenv("SHELL").map { String(cString: $0) }

    unsetenv("SHELL")

    defer {
      if let original = originalShell {
        setenv("SHELL", original, 1)
      } else {
        unsetenv("SHELL")
      }
    }

    let hotKey = HotKey(modifierFlags: .cmd, key: 0, command: "true")
    var executed = false

    hotKey.execute { executed = true }

    #expect(executed)
  }

  @Test("execute(onExecute:): SHELL empty falls back to /bin/bash")
  func executeFallsBackToBashWhenShellEmpty() async throws {
    let originalShell = getenv("SHELL").map { String(cString: $0) }

    setenv("SHELL", "", 1)

    defer {
      if let original = originalShell {
        setenv("SHELL", original, 1)
      } else {
        unsetenv("SHELL")
      }
    }

    let hotKey = HotKey(modifierFlags: .cmd, key: 0, command: "true")
    var executed = false

    hotKey.execute { executed = true }

    #expect(executed)
  }

  @Test("execute(onExecute:): passthrough returns passthrough")
  func executeWithPassthroughReturnsPassthrough() async throws {
    let hotKey = HotKey(modifierFlags: .cmd, key: 0, command: "true", passthrough: true)
    var executed = false

    let result = hotKey.execute { executed = true }

    #expect(executed)
    #expect(result == .passthrough)
  }

  @Test("execute(onExecute:): consumed returns consumed")
  func executeWithoutPassthroughReturnsConsumed() async throws {
    let hotKey = HotKey(modifierFlags: .cmd, key: 0, command: "true", passthrough: false)
    var executed = false

    let result = hotKey.execute { executed = true }

    #expect(executed)
    #expect(result == .consumed)
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
