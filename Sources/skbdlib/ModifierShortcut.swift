import Carbon
import Foundation

public struct ModifierShortcut: Shortcut {
  public var handler: HandlerFunc!

  public let identifier = UUID()

  public var isLeader: Bool = false

  public var keyCode: UInt32?
  public var modifierFlags: UInt32?

  public init() {}

  public init(_ keyCode: UInt32, _ modifierFlags: UInt32) {
    self.keyCode = keyCode
    self.modifierFlags = modifierFlags
  }

  public init(_ keyCode: UInt32, _ modifierFlags: UInt32, _ handler: @escaping HandlerFunc) {
    self.keyCode = keyCode
    self.modifierFlags = modifierFlags
    self.handler = handler
  }
}
