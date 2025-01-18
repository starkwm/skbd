import Testing

@testable import skbdlib

@Suite("Shortcut")
struct ShortcutTests {
  // MARK: Shortcut#identifier

  @Test("Shortcut#identifier (identifiers are unique)")
  func identifier() async throws {
    let shortcut1 = Shortcut(1, 2)
    let shortcut2 = Shortcut(1, 2)

    #expect(shortcut1.identifier != shortcut2.identifier)
  }
}
