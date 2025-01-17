import Carbon
import Foundation

public struct Shortcut {
  public let identifier = UUID()

  public var keyCode: UInt32?
  public var modifierFlags: UInt32?

  public var handler: (() -> Void)!

  public init() {}

  public init(_ keyCode: UInt32, _ modifierFlags: UInt32) {
    self.keyCode = keyCode
    self.modifierFlags = modifierFlags
  }

  public init(_ keyCode: UInt32, _ modifierFlags: UInt32, _ handler: @escaping (() -> Void)) {
    self.keyCode = keyCode
    self.modifierFlags = modifierFlags
    self.handler = handler
  }
}
