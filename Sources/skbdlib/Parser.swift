import Foundation

public class Parser {
  private var lexer: Lexer

  private var currToken: Token?
  private var prevToken: Token?

  private var isAtEnd: Bool { currToken?.type == .endOfStream }

  public init(_ buffer: String) {
    lexer = Lexer(buffer)
  }

  public func parse() throws -> [Shortcut] {
    var shortcuts = [Shortcut]()

    advance()

    while !isAtEnd {
      while check(type: .comment) {
        advance()
      }

      guard !isAtEnd else { break }

      if check(type: .modifier) {
        shortcuts.append(try parseShortcut())
      } else {
        throw ParserError.expectedModifier
      }
    }

    return shortcuts
  }

  private func parseShortcut() throws -> Shortcut {
    let modifierFlags = try parseModifiers()

    guard match(type: .dash) else {
      throw ParserError.expectedModifierFollowedByDash
    }

    guard match(type: .key), let key = prevToken?.text else {
      throw ParserError.expectedDashFollowedByKey
    }

    let keyCode = Key.code(for: key)

    guard match(type: .command), let cmd = prevToken?.text else {
      throw ParserError.expectedColonFollowedByCommand
    }

    let handler = Shortcut.handler(for: cmd)

    return Shortcut(keyCode, modifierFlags, handler)
  }

  private func parseModifiers() throws -> UInt32 {
    var modifiers = [getModifier()]

    while match(type: .plus) {
      guard check(type: .modifier) else {
        throw ParserError.expectedPlusFollowedByModifier
      }

      modifiers.append(getModifier())
    }

    return Modifier.flags(for: modifiers.compactMap { $0 })
  }

  private func getModifier() -> String? {
    advance()
    return prevToken?.text
  }

  private func advance() {
    prevToken = currToken
    currToken = lexer.nextToken(prevToken: prevToken)
  }

  private func check(type: TokenType) -> Bool {
    guard !isAtEnd else { return false }

    return currToken?.type == type
  }

  private func match(type: TokenType) -> Bool {
    guard check(type: type) else { return false }

    advance()

    return true
  }
}
