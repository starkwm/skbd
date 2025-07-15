import AppKit

class KeyWindow: PanelWindow {
  override public var acceptsFirstResponder: Bool { true }
  override public var canBecomeKey: Bool { true }
  override public var canBecomeMain: Bool { true }

  private var statusItem: StatusItem!

  private var handleKey: (UInt16) -> Void

  init(handleKey: @escaping (UInt16) -> Void) {
    self.handleKey = handleKey

    super.init(contentRect: .zero)

    statusItem = StatusItem()
  }

  override public func keyDown(with event: NSEvent) {
    handleKey(event.keyCode)
  }

  public func show() {
    makeKeyAndOrderFront(nil)
    statusItem.show()
  }

  public func hide() {
    close()
    statusItem.hide()
  }

  public func flash() {
    statusItem.flash()
  }
}
