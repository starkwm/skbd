import AppKit
import Carbon

public class Window: PanelWindow, NSWindowDelegate {
  override public var acceptsFirstResponder: Bool { true }
  override public var canBecomeKey: Bool { true }
  override public var canBecomeMain: Bool { true }

  private var sequenceManager: SequenceShortcutManager

  private var statusItem: StatusItem!

  public init(sequenceManager: SequenceShortcutManager) {
    self.sequenceManager = sequenceManager

    super.init(contentRect: .zero)

    statusItem = StatusItem()

    delegate = self
  }

  override public func keyDown(with event: NSEvent) {
    if event.keyCode == UInt16(kVK_Escape) {
      hide()
      return
    }

    sequenceManager.handle(
      keyCode: event.keyCode,
      onAction: { self.hide() },
      onUnknown: { self.flash() }
    )
  }

  public func show() {
    makeKeyAndOrderFront(nil)
    statusItem.show()
  }

  public func hide() {
    close()
    statusItem.hide()
  }

  public func toggle() {
    isVisible ? hide() : show()
  }

  public func flash() {
    statusItem.flash()
  }
}
