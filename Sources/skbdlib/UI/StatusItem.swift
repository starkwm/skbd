import AppKit

class StatusItem {
  private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

  private let image1 = NSImage(systemSymbolName: "dot.square.fill", accessibilityDescription: "filled square dot")
  private let image2 = NSImage(systemSymbolName: "dot.square", accessibilityDescription: "square dot")

  init() {
    statusItem.isVisible = false
    statusItem.button?.image = image1
  }

  func show() {
    statusItem.isVisible = true
  }

  func hide() {
    statusItem.isVisible = false
  }

  func flash() {
    self.statusItem.button?.image = image2

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
      self?.statusItem.button?.image = self?.image1
    }
  }
}
