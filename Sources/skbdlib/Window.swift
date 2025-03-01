import AppKit

class Window: PanelWindow, NSWindowDelegate {
  override var acceptsFirstResponder: Bool { true }
  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { true }

  private var statusItem: StatusItem!

  init() {
    super.init(contentRect: NSRect(x: 0, y: 0, width: 0, height: 0))

    DispatchQueue.main.async {
      self.statusItem = StatusItem()
    }

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

  override func keyDown(with event: NSEvent) {
    print("keyDown:")
    print(event)
  }

  func toggle() {
    if isVisible {
      hide()
    } else {
      show()
    }
  }

  private func show() {
    print("showing window status item...")

    makeKeyAndOrderFront(nil)
    statusItem.show()
  }

  private func hide() {
    print("hiding window and status item...")

    close()
    statusItem.hide()
  }
}
