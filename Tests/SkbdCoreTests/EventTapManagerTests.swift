import Carbon
import CoreGraphics
import Foundation
import Testing

@testable import SkbdCore

@Suite("EventTapManager")
struct EventTapManagerTests {
  @Test("update(configuration:): replaces hotkeys")
  func updateHotKeys() {
    let oldHotKey = HotKey(modifierFlags: [], key: 0, command: "false")
    let newHotKey = HotKey(modifierFlags: [], key: 1, command: "true")
    let manager = EventTapManager(hotKeys: [oldHotKey])

    let source = CGEventSource(stateID: .hidSystemState)
    let oldEvent = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)!
    let newEvent = CGEvent(keyboardEventSource: source, virtualKey: 1, keyDown: true)!
    oldEvent.flags = []
    newEvent.flags = []

    manager.update(configuration: Configuration(hotKeys: [newHotKey]))

    #expect(manager.process(event: oldEvent, type: .keyDown) == oldEvent)
    #expect(manager.process(event: newEvent, type: .keyDown) == nil)
  }

  @Test("process(event:type:): unhandled type")
  func unhandledEvent() {
    let manager = EventTapManager(hotKeys: [])

    let source = CGEventSource(stateID: .hidSystemState)
    let event = CGEvent(
      mouseEventSource: source,
      mouseType: .leftMouseDown,
      mouseCursorPosition: .zero,
      mouseButton: .left
    )!

    let result = manager.process(event: event, type: .leftMouseDown)

    #expect(result == event)
  }

  @Test("process(event:type:): keyDown without match")
  func unmatchedKey() {
    let manager = EventTapManager(hotKeys: [])

    let source = CGEventSource(stateID: .hidSystemState)
    let event = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)!
    event.flags = []

    let result = manager.process(event: event, type: .keyDown)

    #expect(result == event)
  }

  @Test("process(event:type:): keyDown consumed match")
  func consumedKey() {
    let hotKey = HotKey(modifierFlags: [], key: 0, command: "true")
    let manager = EventTapManager(hotKeys: [hotKey])

    let source = CGEventSource(stateID: .hidSystemState)
    let event = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)!
    event.flags = []

    let result = manager.process(event: event, type: .keyDown)

    #expect(result == nil)
  }

  @Test("process(event:type:): keyDown passthrough match")
  func passthroughKey() {
    let hotKey = HotKey(modifierFlags: [], key: 0, command: "true", passthrough: true)
    let manager = EventTapManager(hotKeys: [hotKey])

    let source = CGEventSource(stateID: .hidSystemState)
    let event = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)!
    event.flags = []

    let result = manager.process(event: event, type: .keyDown)

    #expect(result == event)
  }
}
