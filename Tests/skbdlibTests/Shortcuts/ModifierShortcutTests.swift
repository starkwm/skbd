import Carbon
import Testing

@testable import skbdlib

@Suite("ModifierShortcut", .serialized)
struct ModifierShortcutSerializedTests {
  // MARK: - ModifierShortcut.action(for:)

  @Test("ModifierShortcut.action(for:) (with SHELL set)")
  func actionWithShell() async throws {
    setenv("SHELL", "/bin/bash", 1)

    #expect(throws: Never.self) {
      let action = ModifierShortcut.action(for: "true")

      try action()
    }
  }

  @Test("ModifierShortcut.action(for:) (with empty SHELL set)")
  func actionWithEmptyShell() async throws {
    setenv("SHELL", "", 1)

    #expect(throws: Never.self) {
      let action = ModifierShortcut.action(for: "true")

      try action()
    }
  }

  @Test("ModifierShortcut.action(for:) (with unset SHELL set)")
  func actionWithUnsetShell() async throws {
    unsetenv("SHELL")

    #expect(throws: Never.self) {
      let action = ModifierShortcut.action(for: "true")

      try action()
    }
  }

  @Test("ModifierShortcut.action(for:) (with invalid SHELL set)")
  func actionWithInvalidShell() async throws {
    setenv("SHELL", "/bin/invalid", 1)

    #expect(throws: Error.self) {
      let action = ModifierShortcut.action(for: "true")

      try action()
    }
  }

  @Test("ModifierShortcut.action(for:) (with empty command)")
  func actionWithEmptyCommand() async throws {
    #expect(throws: Never.self) {
      let action = ModifierShortcut.action(for: "")

      try action()
    }
  }
}

@Suite("ModifierShortcut")
struct ModifierShortcutTests {
  // MARK: - ModifierShortcut#identifier

  @Test("ModifierShortcut#identifier (identifiers are unique)")
  func identifier() async throws {
    let shortcut1 = ModifierShortcut(1, 2) {}
    let shortcut2 = ModifierShortcut(1, 2) {}

    #expect(shortcut1.identifier != shortcut2.identifier)
  }
}
