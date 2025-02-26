import Carbon
import Testing

@testable import skbdlib

@Suite("ModifierShortcut", .serialized)
struct ModifierShortcutSerializedTests {
  // MARK: - ModifierShortcut.handler(for:)

  @Test("ModifierShortcut.handler(for:) (with SHELL set)")
  func handlerWithShell() async throws {
    setenv("SHELL", "/bin/bash", 1)

    #expect(throws: Never.self) {
      let handler = ModifierShortcut.handler(for: "true")

      try handler()
    }
  }

  @Test("ModifierShortcut.handler(for:) (with empty SHELL set)")
  func handlerWithEmptyShell() async throws {
    setenv("SHELL", "", 1)

    #expect(throws: Never.self) {
      let handler = ModifierShortcut.handler(for: "true")

      try handler()
    }
  }

  @Test("ModifierShortcut.handler(for:) (with unset SHELL set)")
  func handlerWithUnsetShell() async throws {
    unsetenv("SHELL")

    #expect(throws: Never.self) {
      let handler = ModifierShortcut.handler(for: "true")

      try handler()
    }
  }

  @Test("ModifierShortcut.handler(for:) (with invalid SHELL set)")
  func handlerWithInvalidShell() async throws {
    setenv("SHELL", "/bin/invalid", 1)

    #expect(throws: Error.self) {
      let handler = ModifierShortcut.handler(for: "true")

      try handler()
    }
  }

  @Test("ModifierShortcut.handler(for:) (with empty command)")
  func handlerWithEmptyCommand() async throws {
    #expect(throws: Never.self) {
      let handler = ModifierShortcut.handler(for: "")

      try handler()
    }
  }
}

@Suite("ModifierShortcut")
struct ModifierShortcutTests {
  // MARK: - ModifierShortcut#identifier

  @Test("ModifierShortcut#identifier (identifiers are unique)")
  func identifier() async throws {
    let shortcut1 = ModifierShortcut(1, 2)
    let shortcut2 = ModifierShortcut(1, 2)

    #expect(shortcut1.identifier != shortcut2.identifier)
  }
}
