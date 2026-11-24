import AppKit
import CoreGraphics

public class EventTapManager: @unchecked Sendable {
  private var eventTap: CFMachPort?
  private var runLoopSource: CFRunLoopSource?

  private var configuration: Configuration

  public init(configuration: Configuration) {
    self.configuration = configuration
  }

  deinit {
    if let eventTap {
      CGEvent.tapEnable(tap: eventTap, enable: false)
      CFMachPortInvalidate(eventTap)
    }

    if let runLoopSource {
      CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
    }
  }

  public func begin() -> Result<Void, EventTapError> {
    guard eventTap == nil, runLoopSource == nil else { return .success(()) }

    let callback: CGEventTapCallBack = { _, type, event, refcon in
      guard let refcon else { return Unmanaged.passUnretained(event) }

      let manager = Unmanaged<EventTapManager>.fromOpaque(refcon).takeUnretainedValue()
      let result = manager.process(event: event, type: type)

      guard let result else { return nil }

      return Unmanaged.passUnretained(result)
    }

    eventTap = CGEvent.tapCreate(
      tap: .cghidEventTap,
      place: .headInsertEventTap,
      options: .defaultTap,
      eventsOfInterest: (1 << CGEventType.keyDown.rawValue),
      callback: callback,
      userInfo: Unmanaged.passUnretained(self).toOpaque()
    )

    guard let eventTap else { return .failure(.creationFailed) }

    runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)

    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
    CGEvent.tapEnable(tap: eventTap, enable: true)

    return .success(())
  }

  public func update(configuration: Configuration) {
    self.configuration = configuration
  }

  func process(event: CGEvent, type: CGEventType) -> CGEvent? {
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
      guard let eventTap else { return event }

      let reason = type == .tapDisabledByTimeout ? "timeout" : "user input"
      fputs("event tap disabled by \(reason), re-enabling\n", stderr)
      fflush(stderr)

      CGEvent.tapEnable(tap: eventTap, enable: true)
    case .keyDown:
      let eventHotKey = HotKey.from(event: event)
      let hotKey = configuration.hotKeys.first { $0.matches(eventHotKey) }

      guard let hotKey else { return event }

      if isFrontmostApplicationBlocked() { return event }

      let result = hotKey.execute()

      if case .consumed = result { return nil }

      return event
    default:
      break
    }

    return event
  }

  // Looking up the frontmost application is a call to another process, so only make it for
  // key presses that match a shortcut and only when something is blocked.
  private func isFrontmostApplicationBlocked() -> Bool {
    guard !configuration.blockList.isEmpty else { return false }

    guard let processName = NSWorkspace.shared.frontmostApplication?.localizedName else {
      return false
    }

    return configuration.blockList.contains(processName)
  }
}

public enum EventTapError: Error, LocalizedError {
  case creationFailed
}

extension EventTapError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .creationFailed:
      return "failed to create event tap"
    }
  }
}
