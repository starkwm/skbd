import Foundation

protocol HotKeyShortcut: Shortcut {
  var identifier: UUID { get }
  var keyCode: UInt32 { get }
  var modifierFlags: UInt32 { get }
}
