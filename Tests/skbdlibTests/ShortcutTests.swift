import XCTest

@testable import skbdlib

final class ShortcutTests: XCTestCase {
  // MARK: Shortcut#identifier

  func testIdentifierIsUnique() {
    let shortcut1 = Shortcut(1, 2)
    let shortcut2 = Shortcut(1, 2)

    XCTAssertNotEqual(shortcut1.identifier, shortcut2.identifier)
  }
}
