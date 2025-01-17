import Foundation

private func resolveShell() -> String {
  if let shell = ProcessInfo.processInfo.environment["SHELL"] {
    if !shell.isEmpty {
      return shell
    }
  }

  return "/bin/bash"
}

public class Parser {
  private var lexer: Lexer

  private var currToken: Token?
  private var prevToken: Token?

  private var shortcuts = [Shortcut]()

  public init(_ buffer: String) {
    lexer = Lexer(buffer)
  }

  public func parse() throws -> [Shortcut] {
    shortcuts.removeAll()

    advance()

    while !isEndOfFile() {
      while check(type: .comment) {
        advance()
      }

      if isEndOfFile() {
        break
      }

      if check(type: .modifier) {
        shortcuts.append(try parseShortcuts())
      } else {
        throw ParserError.expectedModifier
      }
    }

    return shortcuts
  }

  private func parseShortcuts() throws -> Shortcut {
    var shortcut = Shortcut()

    let modifier = match(type: .modifier)

    if modifier {
      let modifiers = try parseModifier()
      shortcut.modifierFlags = Modifier.flags(for: modifiers)
    }

    if modifier {
      if !match(type: .dash) {
        throw ParserError.expectedModifierFollowedByDash
      }
    }

    if match(type: .key) {
      let key = prevToken!.text!
      shortcut.keyCode = Key.code(for: key)
    } else {
      throw ParserError.expectedDashFollowedByKey
    }

    if match(type: .command) {
      let command = self.prevToken!.text!

      let handler: () -> Void = {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: resolveShell())
        proc.arguments = ["-c", command]
        try? proc.run()
      }

      shortcut.handler = handler
    } else {
      throw ParserError.expectedColonFollowedByCommand
    }

    return shortcut
  }

  private func parseModifier() throws -> [String] {
    var modifiers = [prevToken!.text!]

    if match(type: .plus) {
      if match(type: .modifier) {
        modifiers.append(contentsOf: try parseModifier())
      } else {
        throw ParserError.expectedPlusFollowedByModifier
      }
    }

    return modifiers
  }

  private func isEndOfFile() -> Bool {
    guard let token = currToken else {
      return false
    }

    return token.type == .endOfStream
  }

  private func advance() {
    if !isEndOfFile() {
      prevToken = currToken
      currToken = lexer.getToken()
    }
  }

  private func check(type: TokenType) -> Bool {
    if isEndOfFile() {
      return false
    }

    return currToken?.type == type
  }

  private func match(type: TokenType) -> Bool {
    if check(type: type) {
      advance()
      return true
    }

    return false
  }
}
