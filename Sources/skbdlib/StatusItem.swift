import AppKit

class StatusItem {
  private let statusItem = NSStatusBar.system.statusItem(withLength: 16)

  init() {
    statusItem.isVisible = false

    guard let iconURL = Bundle.module.url(forResource: "Resources/icon", withExtension: "png") else { return }

    statusItem.button?.image = NSImage(contentsOf: iconURL)
    statusItem.button?.image?.isTemplate = true
    statusItem.button?.image?.size = NSSize(width: 16, height: 16)
  }

  func show() {
    statusItem.isVisible = true
  }

  func hide() {
    statusItem.isVisible = false
  }
}
