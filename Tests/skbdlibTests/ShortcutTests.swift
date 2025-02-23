import Carbon
import Testing

@testable import skbdlib

@Suite("Shortcut", .serialized)
struct ShortcutSerializedTests {
  // MARK: - Shortcut.handler(for:)

  @Test("Shortcut.handler(for:) (with SHELL set)")
  func handlerWithShell() async throws {
    setenv("SHELL", "/bin/bash", 1)

    #expect(throws: Never.self) {
      let handler = Shortcut.handler(for: "true")

      try handler()
    }
  }

  @Test("Shortcut.handler(for:) (with empty SHELL set)")
  func handlerWithEmptyShell() async throws {
    setenv("SHELL", "", 1)

    #expect(throws: Never.self) {
      let handler = Shortcut.handler(for: "true")

      try handler()
    }
  }

  @Test("Shortcut.handler(for:) (with unset SHELL set)")
  func handlerWithUnsetShell() async throws {
    unsetenv("SHELL")

    #expect(throws: Never.self) {
      let handler = Shortcut.handler(for: "true")

      try handler()
    }
  }

  @Test("Shortcut.handler(for:) (with invalid SHELL set)")
  func handlerWithInvalidShell() async throws {
    setenv("SHELL", "/bin/invalid", 1)

    #expect(throws: Error.self) {
      let handler = Shortcut.handler(for: "true")

      try handler()
    }
  }

  @Test("Shortcut.handler(for:) (with empty command)")
  func handlerWithEmptyCommand() async throws {
    #expect(throws: Never.self) {
      let handler = Shortcut.handler(for: "")

      try handler()
    }
  }
}

@Suite("Shortcut")
struct ShortcutTests {
  // MARK: - Shortcut#identifier

  @Test("Shortcut#identifier (identifiers are unique)")
  func identifier() async throws {
    let shortcut1 = Shortcut(1, 2)
    let shortcut2 = Shortcut(1, 2)

    #expect(shortcut1.identifier != shortcut2.identifier)
  }
}
