import Carbon
import Testing

@testable import skbdlib

@Suite("ShortcutManager", .serialized)
class ShortcutManagerTests {
  deinit {
    ShortcutManager.stop()
    ShortcutManager.reset()

    ShortcutManager.registerEventHotKeyFunc = RegisterEventHotKey
  }

  // MARK: shortcutEventHandler

  @Test("shortcutEventHandler() (processes event and calls shortcut handler)")
  func shortcutEventHandler() async throws {
    var called = false

    let shortcut = Shortcut(123, 456) { called = true }

    ShortcutManager.register(shortcut: shortcut)
    let box = try #require(ShortcutManager.box(for: shortcut))

    let event = createEventRef(signature: skbdEventHotKeySignature, id: box.eventHotKeyID)
    let status = skbdlib.shortcutEventHandler(nil, event: event, nil)

    #expect(status == noErr)
    #expect(called)
  }

  // MARK: ShortcutManager.register

  @Test("ShortcutManager.register(shortcut:) (with valid shortcut)")
  func registerValidShortcut() async throws {
    let shortcut = Shortcut(123, 456)

    ShortcutManager.register(shortcut: shortcut)

    #expect(ShortcutManager.box(for: shortcut) != nil)
  }

  @Test("ShortcutManager.register(shortcut:) (with already registered shortcut)")
  func registerWithAlreadyRegisteredShortcut() async throws {
    let shortcut = Shortcut(123, 456)

    ShortcutManager.register(shortcut: shortcut)
    ShortcutManager.register(shortcut: shortcut)

    #expect(ShortcutManager.box(for: shortcut) != nil)
  }

  @Test("ShortcutManager.register(shortcut:) (with shortcut missing keycode)")
  func registerWithShortcutMissingKeyCode() async throws {
    var shortcut = Shortcut()
    shortcut.modifierFlags = 456

    ShortcutManager.register(shortcut: shortcut)

    #expect(ShortcutManager.box(for: shortcut) == nil)
  }

  @Test("ShortcutManager.register(shortcut:) (with shortcut missing modifier flags)")
  func registerWithShortcutMissingModifierFlags() async throws {
    var shortcut = Shortcut()
    shortcut.keyCode = 123

    ShortcutManager.register(shortcut: shortcut)

    #expect(ShortcutManager.box(for: shortcut) == nil)
  }

  @Test("ShortcutManager.register(shortcut:) (when RegisterEventHotKey fails)")
  func registerWhenRegisterEventHotKeyFails() async throws {
    ShortcutManager.registerEventHotKeyFunc = { (_, _, _, _, _, _) in OSStatus(eventHotKeyInvalidErr) }

    let shortcut = Shortcut(123, 456)

    ShortcutManager.register(shortcut: shortcut)

    #expect(ShortcutManager.box(for: shortcut) == nil)
  }

  // MARK: ShortcutManager.unregister

  @Test("ShortcutManager.unregister(shortcut:) (with registered shortcut)")
  func unregisterWithRegisteredShortcut() async throws {
    let shortcut = Shortcut(123, 456)

    ShortcutManager.register(shortcut: shortcut)

    #expect(ShortcutManager.box(for: shortcut) != nil)

    ShortcutManager.unregister(shortcut: shortcut)

    #expect(ShortcutManager.box(for: shortcut) == nil)
  }

  @Test("ShortcutManager.unregister(shortcut:) (with unregistered shortcut)")
  func unregisterWithUnregisteredShortcut() async throws {
    let shortcut = Shortcut(123, 456)

    ShortcutManager.unregister(shortcut: shortcut)

    #expect(ShortcutManager.box(for: shortcut) == nil)
  }

  // MARK: ShortcutManager.start

  @Test("ShortcutManager.start() (when shortcuts registered)")
  func startWhenShortcutsRegistered() async throws {
    let shortcut = Shortcut(123, 456)

    ShortcutManager.register(shortcut: shortcut)

    #expect(ShortcutManager.start())
  }

  @Test("ShortcutManager.start() (when no shortcuts registered)")
  func startWhenNoShortcutsRegistered() async throws {
    #expect(!ShortcutManager.start())
  }

  @Test("ShortcutManager.start() (when already started)")
  func startWhenAlreadyStarted() async throws {
    let shortcut = Shortcut(123, 456)

    ShortcutManager.register(shortcut: shortcut)

    #expect(ShortcutManager.start())
    #expect(!ShortcutManager.start())
  }

  // MARK: ShortcutManager.stop

  @Test("ShortcutManager.stop() (when shortcuts registered)")
  func stopWhenShortcutsRegistered() async throws {
    let shortcut = Shortcut(123, 456)

    ShortcutManager.register(shortcut: shortcut)

    #expect(ShortcutManager.start())
    #expect(ShortcutManager.stop())
  }

  @Test("ShortcutManager.stop() (when not started)")
  func stopWhenNotStarted() async throws {
    #expect(!ShortcutManager.stop())
  }

  // MARK: ShortcutManager.reset

  @Test("ShortcutManager.reset() (when shortcuts registered)")
  func resetWhenShortcutsRegistered() async throws {
    let shortcut1 = Shortcut(123, 456)
    let shortcut2 = Shortcut(321, 654)

    ShortcutManager.register(shortcut: shortcut1)
    ShortcutManager.register(shortcut: shortcut2)

    #expect(ShortcutManager.box(for: shortcut1) != nil)
    #expect(ShortcutManager.box(for: shortcut2) != nil)

    ShortcutManager.reset()

    #expect(ShortcutManager.box(for: shortcut1) == nil)
    #expect(ShortcutManager.box(for: shortcut2) == nil)
  }

  // MARK: ShortcutManager.box

  @Test("ShortcutManager.box(for:) (with registered shortcut)")
  func boxWithRegisteredShortcut() async throws {
    let shortcut = Shortcut(123, 456)

    ShortcutManager.register(shortcut: shortcut)

    #expect(ShortcutManager.box(for: shortcut) != nil)
  }

  @Test("ShortcutManager.box(for:) (with unregistered shortcut)")
  func boxWithUnregisteredShortcut() async throws {
    let shortcut = Shortcut(123, 456)

    #expect(ShortcutManager.box(for: shortcut) == nil)
  }

  // MARK: ShortcutManager.handleCarbonEvent

  @Test("ShortcutManager.handleCarbonEvent() (with valid event)")
  func handleCarbonEventWithValidEvent() async throws {
    var called = false

    let shortcut = Shortcut(123, 456) { called = true }

    ShortcutManager.register(shortcut: shortcut)
    let box = try #require(ShortcutManager.box(for: shortcut))

    let event = createEventRef(signature: skbdEventHotKeySignature, id: box.eventHotKeyID)
    let status = ShortcutManager.handleCarbonEvent(event)

    #expect(status == noErr)
    #expect(called)
  }

  @Test("ShortcutManager.handleCarbonEvent() (with nil event)")
  func handleCarbonEventWithNilEvent() async throws {
    let status = ShortcutManager.handleCarbonEvent(nil)

    #expect(status == OSStatus(eventNotHandledErr))
  }

  @Test("ShortcutManager.handleCarbonEvent() (with no event parameter)")
  func handleCarbonEventWithNoEventParamter() async throws {
    let event = createEventRefWithNoEventParameter()
    let status = ShortcutManager.handleCarbonEvent(event)

    #expect(status == OSStatus(eventParameterNotFoundErr))
  }

  @Test("ShortcutManager.handleCarbonEvent() (with invalid signature)")
  func handleCarbonEventWithInvalidSignature() async throws {
    let shortcut = Shortcut(123, 456)

    ShortcutManager.register(shortcut: shortcut)
    let box = try #require(ShortcutManager.box(for: shortcut))

    let event = createEventRefWithInvalidEventHotKeySignature(eventHotKeyID: box.eventHotKeyID)
    let status = ShortcutManager.handleCarbonEvent(event)

    #expect(status == OSStatus(eventNotHandledErr))
  }

  @Test("ShortcutManager.handleCarbonEvent() (with invalid shortcut ID)")
  func handleCarbonEventWithInvalidShortcutID() async throws {
    let event = createEventRefWithInvalidEventHotKeyID()
    let status = ShortcutManager.handleCarbonEvent(event)

    #expect(status == OSStatus(eventNotHandledErr))
  }

  @Test("ShortcutManager.handleCarbonEvent() (with broken shortcut handler)")
  func handleCarbonEventWithBrokenShortcutHandler() async throws {
    setenv("SHELL", "/bin/invalid", 1)

    let handler = Shortcut.handler(for: "true")
    let shortcut = Shortcut(123, 456, handler)

    ShortcutManager.register(shortcut: shortcut)
    let box = try #require(ShortcutManager.box(for: shortcut))

    let event = createEventRef(signature: skbdEventHotKeySignature, id: box.eventHotKeyID)
    let status = ShortcutManager.handleCarbonEvent(event)

    #expect(status == OSStatus(eventInternalErr))
  }
}
