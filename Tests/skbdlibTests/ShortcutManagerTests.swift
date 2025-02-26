import Carbon
import Testing

@testable import skbdlib

@Suite("ShortcutManager", .serialized)
class ShortcutManagerTests {
  let shortcutManager = ShortcutManager()

  // MARK: - shortcutEventHandler

  @Test("shortcutEventHandler() (processes event and calls shortcut handler)")
  func shortcutEventHandler() async throws {
    var called = false

    let shortcut = ModifierShortcut(1, 456) { called = true }

    shortcutManager.register(shortcut: shortcut)
    let box = try #require(shortcutManager.box(for: shortcut))

    let event = createEventRef(signature: skbdEventHotKeySignature, id: box.eventHotKeyID)
    let userData = Unmanaged.passUnretained(shortcutManager).toOpaque()
    let status = skbdlib.shortcutEventHandler(nil, event: event, userData: userData)

    #expect(status == noErr)
    #expect(called)
  }

  // MARK: - ShortcutManager#register

  @Test("ShortcutManager#register(shortcut:) (with valid shortcut)")
  func registerValidShortcut() async throws {
    let shortcut = ModifierShortcut(2, 456)

    shortcutManager.register(shortcut: shortcut)

    #expect(shortcutManager.box(for: shortcut) != nil)
  }

  @Test("ShortcutManager#register(shortcut:) (with already registered shortcut)")
  func registerWithAlreadyRegisteredShortcut() async throws {
    let shortcut = ModifierShortcut(3, 456)

    shortcutManager.register(shortcut: shortcut)
    shortcutManager.register(shortcut: shortcut)

    #expect(shortcutManager.box(for: shortcut) != nil)
  }

  @Test("ShortcutManager#register(shortcut:) (with shortcut missing keycode)")
  func registerWithShortcutMissingKeyCode() async throws {
    var shortcut = ModifierShortcut()
    shortcut.modifierFlags = 456

    shortcutManager.register(shortcut: shortcut)

    #expect(shortcutManager.box(for: shortcut) == nil)
  }

  @Test("ShortcutManager#register(shortcut:) (with shortcut missing modifier flags)")
  func registerWithShortcutMissingModifierFlags() async throws {
    var shortcut = ModifierShortcut()
    shortcut.keyCode = 5

    shortcutManager.register(shortcut: shortcut)

    #expect(shortcutManager.box(for: shortcut) == nil)
  }

  @Test("ShortcutManager#register(shortcut:) (when RegisterEventHotKey fails)")
  func registerWhenRegisterEventHotKeyFails() async throws {
    shortcutManager.registerEventHotKeyFunc = { (_, _, _, _, _, _) in OSStatus(eventHotKeyInvalidErr) }

    let shortcut = ModifierShortcut(6, 456)

    shortcutManager.register(shortcut: shortcut)

    #expect(shortcutManager.box(for: shortcut) == nil)
  }

  // MARK: - ShortcutManager#unregister

  @Test("ShortcutManager#unregister(shortcut:) (with registered shortcut)")
  func unregisterWithRegisteredShortcut() async throws {
    let shortcut = ModifierShortcut(7, 456)

    shortcutManager.register(shortcut: shortcut)

    #expect(shortcutManager.box(for: shortcut) != nil)

    shortcutManager.unregister(shortcut: shortcut)

    #expect(shortcutManager.box(for: shortcut) == nil)
  }

  @Test("ShortcutManager#unregister(shortcut:) (with unregistered shortcut)")
  func unregisterWithUnregisteredShortcut() async throws {
    let shortcut = ModifierShortcut(8, 456)

    shortcutManager.unregister(shortcut: shortcut)

    #expect(shortcutManager.box(for: shortcut) == nil)
  }

  // MARK: - ShortcutManager#start

  @Test("ShortcutManager#start() (when shortcuts registered)")
  func startWhenShortcutsRegistered() async throws {
    let shortcut = ModifierShortcut(9, 456)

    shortcutManager.register(shortcut: shortcut)

    #expect(shortcutManager.start())
  }

  @Test("ShortcutManager#start() (when no shortcuts registered)")
  func startWhenNoShortcutsRegistered() async throws {
    #expect(!shortcutManager.start())
  }

  @Test("ShortcutManager#start() (when already started)")
  func startWhenAlreadyStarted() async throws {
    let shortcut = ModifierShortcut(11, 456)

    shortcutManager.register(shortcut: shortcut)

    #expect(shortcutManager.start())
    #expect(!shortcutManager.start())
  }

  // MARK: - ShortcutManager#stop

  @Test("ShortcutManager#stop() (when shortcuts registered)")
  func stopWhenShortcutsRegistered() async throws {
    let shortcut = ModifierShortcut(12, 456)

    shortcutManager.register(shortcut: shortcut)

    #expect(shortcutManager.start())
    #expect(shortcutManager.stop())
  }

  @Test("ShortcutManager.stop() (when not started)")
  func stopWhenNotStarted() async throws {
    #expect(!shortcutManager.stop())
  }

  // MARK: - ShortcutManager#reset

  @Test("ShortcutManager#reset() (when shortcuts registered)")
  func resetWhenShortcutsRegistered() async throws {
    let shortcut1 = ModifierShortcut(14, 456)
    let shortcut2 = ModifierShortcut(15, 654)

    shortcutManager.register(shortcut: shortcut1)
    shortcutManager.register(shortcut: shortcut2)

    #expect(shortcutManager.box(for: shortcut1) != nil)
    #expect(shortcutManager.box(for: shortcut2) != nil)

    shortcutManager.reset()

    #expect(shortcutManager.box(for: shortcut1) == nil)
    #expect(shortcutManager.box(for: shortcut2) == nil)
  }

  // MARK: - ShortcutManager#box

  @Test("ShortcutManager#box(for:) (with registered shortcut)")
  func boxWithRegisteredShortcut() async throws {
    let shortcut = ModifierShortcut(16, 456)

    shortcutManager.register(shortcut: shortcut)

    #expect(shortcutManager.box(for: shortcut) != nil)
  }

  @Test("ShortcutManager#box(for:) (with unregistered shortcut)")
  func boxWithUnregisteredShortcut() async throws {
    let shortcut = ModifierShortcut(17, 456)

    #expect(shortcutManager.box(for: shortcut) == nil)
  }

  // MARK: - ShortcutManager.handleCarbonEvent

  @Test("ShortcutManager#handleCarbonEvent() (with valid event)")
  func handleCarbonEventWithValidEvent() async throws {
    var called = false

    let shortcut = ModifierShortcut(18, 456) { called = true }

    shortcutManager.register(shortcut: shortcut)
    let box = try #require(shortcutManager.box(for: shortcut))

    let event = createEventRef(signature: skbdEventHotKeySignature, id: box.eventHotKeyID)
    let status = shortcutManager.handleCarbonEvent(event)

    #expect(status == noErr)
    #expect(called)
  }

  @Test("ShortcutManager#handleCarbonEvent() (with nil event)")
  func handleCarbonEventWithNilEvent() async throws {
    let status = shortcutManager.handleCarbonEvent(nil)

    #expect(status == OSStatus(eventNotHandledErr))
  }

  @Test("ShortcutManager#handleCarbonEvent() (with no event parameter)")
  func handleCarbonEventWithNoEventParamter() async throws {
    let event = createEventRefWithNoEventParameter()
    let status = shortcutManager.handleCarbonEvent(event)

    #expect(status == OSStatus(eventParameterNotFoundErr))
  }

  @Test("ShortcutManager#handleCarbonEvent() (with invalid signature)")
  func handleCarbonEventWithInvalidSignature() async throws {
    let shortcut = ModifierShortcut(21, 456)

    shortcutManager.register(shortcut: shortcut)
    let box = try #require(shortcutManager.box(for: shortcut))

    let event = createEventRefWithInvalidEventHotKeySignature(eventHotKeyID: box.eventHotKeyID)
    let status = shortcutManager.handleCarbonEvent(event)

    #expect(status == OSStatus(eventNotHandledErr))
  }

  @Test("ShortcutManager#handleCarbonEvent() (with invalid shortcut ID)")
  func handleCarbonEventWithInvalidShortcutID() async throws {
    let event = createEventRefWithInvalidEventHotKeyID()
    let status = shortcutManager.handleCarbonEvent(event)

    #expect(status == OSStatus(eventNotHandledErr))
  }

  @Test("ShortcutManager#handleCarbonEvent() (with broken shortcut handler)")
  func handleCarbonEventWithBrokenShortcutHandler() async throws {
    setenv("SHELL", "/bin/invalid", 1)

    let handler = ModifierShortcut.handler(for: "true")
    let shortcut = ModifierShortcut(23, 456, handler)

    shortcutManager.register(shortcut: shortcut)
    let box = try #require(shortcutManager.box(for: shortcut))

    let event = createEventRef(signature: skbdEventHotKeySignature, id: box.eventHotKeyID)
    let status = shortcutManager.handleCarbonEvent(event)

    #expect(status == OSStatus(eventInternalErr))
  }
}
