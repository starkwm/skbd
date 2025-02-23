import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
  var window: Window!
  

  func applicationDidFinishLaunching(_: Notification) {
    window = Window()
  }

  func isVisible() -> Bool { window.isVisible }

  func show() {
    window.show()
  }

  func hide() {
    window.hide()
  }
}
