import Testing

@testable import skbdlib

@Suite("Shortcut", .serialized)
struct ShortcutSerializedTests {
  // MARK: Shortcut.handler(for:)

  //  @Test("Parser#parse() (shortcut.handler() callable with SHELL set)")
  //  func parseShortcutHandlerCallable() async throws {
  //    setenv("SHELL", "/bin/bash", 1)
  //
  //    #expect(throws: Never.self) {
  //      let shortcuts = try Parser("opt+ctrl-a: echo").parse()
  //
  //      #expect(shortcuts.count == 1)
  //
  //      try shortcuts[0].handler()
  //    }
  //  }
  //
  //  @Test("Parser#parse() (shortcut.handler() callable with empty SHELL)")
  //  func parseShortcutHandlerCallableWithEmptyShell() async throws {
  //    setenv("SHELL", "", 1)
  //
  //    #expect(throws: Never.self) {
  //      let shortcuts = try Parser("opt+ctrl-a: echo").parse()
  //
  //      #expect(shortcuts.count == 1)
  //
  //      try shortcuts[0].handler()
  //    }
  //  }
  //
  //  @Test("Parser#parse() (shortcut.handler() callable with no SHELL set)")
  //  func parseShortcutHandlerCallableWithNoShell() async throws {
  //    unsetenv("SHELL")
  //
  //    #expect(throws: Never.self) {
  //      let shortcuts = try Parser("opt+ctrl-a: echo").parse()
  //
  //      #expect(shortcuts.count == 1)
  //
  //      try shortcuts[0].handler()
  //    }
}

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
