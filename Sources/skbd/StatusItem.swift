import AppKit

class StatusItem {
  private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

  init() {
    let statusItemIconURL = Bundle.module.url(forResource: "Resources/StatusItemIcon", withExtension: "png")

    guard let statusItemIconURL = statusItemIconURL else { return }

    statusItem.button?.image = NSImage(contentsOf: statusItemIconURL)
    statusItem.button?.image?.isTemplate = true
  }

  func show() {
    statusItem.isVisible = true
  }

  func hide() {
    statusItem.isVisible = false
  }
}
