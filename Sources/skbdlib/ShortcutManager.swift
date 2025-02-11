import Carbon

let skbdEventHotKeySignature = "skbd".utf16.reduce(0) { ($0 << 8) + OSType($1) }

func shortcutEventHandler(_: EventHandlerCallRef?, event: EventRef?, userData: UnsafeMutableRawPointer?) -> OSStatus {
  let instance = Unmanaged<ShortcutManager>.fromOpaque(userData!).takeUnretainedValue()
  return instance.handleCarbonEvent(event)
}

public class ShortcutManager {
  struct ShortcutBox {
    let shortcut: Shortcut
    let eventHotKeyID: UInt32
    let eventHotKey: EventHotKeyRef
  }

  public var registerEventHotKeyFunc = RegisterEventHotKey

  private var shortcuts = [UInt32: ShortcutBox]()

  private var shortcutsCount: UInt32 = 0

  private var eventHandler: EventHandlerRef?

  public init() {}

  deinit {
    stop()
    reset()
  }

  public func register(shortcut: Shortcut) {
    if shortcuts.values.contains(where: { $0.shortcut.identifier == shortcut.identifier }) {
      return
    }

    guard let keyCode = shortcut.keyCode, let keyModifiers = shortcut.modifierFlags else {
      return
    }

    shortcutsCount += 1

    var eventHotKeyRef: EventHotKeyRef?

    let registerErr = registerEventHotKeyFunc(
      keyCode,
      keyModifiers,
      EventHotKeyID(signature: skbdEventHotKeySignature, id: shortcutsCount),
      GetEventDispatcherTarget(),
      0,
      &eventHotKeyRef
    )

    guard registerErr == noErr, let eventHotKey = eventHotKeyRef else {
      return
    }

    let box = ShortcutBox(shortcut: shortcut, eventHotKeyID: shortcutsCount, eventHotKey: eventHotKey)
    shortcuts[box.eventHotKeyID] = box
  }

  public func unregister(shortcut: Shortcut) {
    guard let box = box(for: shortcut) else {
      return
    }

    UnregisterEventHotKey(box.eventHotKey)

    shortcuts.removeValue(forKey: box.eventHotKeyID)
  }

  public func start() -> Bool {
    if shortcuts.count == 0 || eventHandler != nil {
      return false
    }

    let ptr = Unmanaged.passUnretained(self).toOpaque()

    let eventSpec = [
      EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
    ]

    InstallEventHandler(
      GetEventDispatcherTarget(),
      shortcutEventHandler,
      1,
      eventSpec,
      ptr,
      &eventHandler
    )

    return true
  }

  @discardableResult
  public func stop() -> Bool {
    if eventHandler != nil {
      RemoveEventHandler(eventHandler)
      eventHandler = nil
      return true
    }

    return false
  }

  public func reset() {
    for box in shortcuts.values {
      self.unregister(shortcut: box.shortcut)
    }
  }

  func box(for shortcut: Shortcut) -> ShortcutBox? {
    for box in shortcuts.values where box.shortcut.identifier == shortcut.identifier {
      return box
    }

    return nil
  }

  func handleCarbonEvent(_ event: EventRef?) -> OSStatus {
    guard let event = event else {
      return OSStatus(eventNotHandledErr)
    }

    var eventHotKeyID = EventHotKeyID()

    let err = GetEventParameter(
      event,
      UInt32(kEventParamDirectObject),
      UInt32(typeEventHotKeyID),
      nil,
      MemoryLayout<EventHotKeyID>.size,
      nil,
      &eventHotKeyID
    )

    if err != noErr {
      return err
    }

    guard eventHotKeyID.signature == skbdEventHotKeySignature, let shortcut = shortcuts[eventHotKeyID.id]?.shortcut
    else {
      return OSStatus(eventNotHandledErr)
    }

    do {
      try shortcut.handler()
    } catch {
      return OSStatus(eventInternalErr)
    }

    return noErr
  }
}
