import AppKit

class Window: PanelWindow, NSWindowDelegate {
  var statusItem: StatusItem!

  override var acceptsFirstResponder: Bool { true }
  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { true }

  init() {
    statusItem = StatusItem()

    super.init(contentRect: NSRect(x: 0, y: 0, width: 50, height: 50))

    delegate = self
  }

  func windowDidResignKey(_: Notification) {
    if isVisible {
      hide()
    }
  }

  override func makeKeyAndOrderFront(_ sender: Any?) {
    super.makeKeyAndOrderFront(sender)
  }

  override func performKeyEquivalent(with event: NSEvent) -> Bool {
    print("performKeyEquivalent:")
    print(event)
    return false
  }

  override func keyDown(with event: NSEvent) {
    print("keyDown:")
    print(event)
  }

  func show(afterOpen: (() -> Void)? = nil) {
    print("showing window and status item...")

    makeKeyAndOrderFront(nil)
    statusItem.show()

    afterOpen?()
  }

  func hide(afterClose: (() -> Void)? = nil) {
    print("hiding window and status item...")

    self.close()
    statusItem.hide()

    afterClose?()
  }
}
