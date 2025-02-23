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

      if isAtEnd {
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
      shortcut.handler = Shortcut.handler(for: prevToken!.text!)
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
