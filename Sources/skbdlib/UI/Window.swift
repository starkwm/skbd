import AppKit

public class Window: PanelWindow, NSWindowDelegate, Presentable {
  override public var acceptsFirstResponder: Bool { true }
  override public var canBecomeKey: Bool { true }
  override public var canBecomeMain: Bool { true }

  private var statusItem: StatusItem!

  public init() {
    super.init(contentRect: NSRect(x: 0, y: 0, width: 0, height: 0))

    DispatchQueue.main.async {
      self.statusItem = StatusItem()
    }

    delegate = self
  }

  public func windowDidResignKey(_: Notification) {
    if isVisible {
      hide()
    }
  }

  override public func makeKeyAndOrderFront(_ sender: Any?) {
    super.makeKeyAndOrderFront(sender)
  }

  override public func keyDown(with event: NSEvent) {
    print("keyDown:")
    print(event)

    if event.keyCode == 0x35 {
      // TODO: esc pressed
      hide()
    }
  }

  public func show() {
    makeKeyAndOrderFront(nil)
    statusItem.show()
  }

  public func hide() {
    close()
    statusItem.hide()
  }
}
