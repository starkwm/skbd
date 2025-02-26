import Foundation

class Parser {
  private var lexer: Lexer

  private var currToken: Token?
  private var prevToken: Token?

  private var isAtEnd: Bool { currToken?.type == .endOfStream }

  init(_ buffer: String) {
    lexer = Lexer(buffer)

    advance()
  }

  func parse() throws -> [Shortcut] {
    var parsedLeaderShortcut = false
    var shortcuts = [Shortcut]()

    while !isAtEnd {
      while check(type: .comment) {
        advance()
      }

      guard !isAtEnd else { break }

      if match(type: .leader) {
        if parsedLeaderShortcut {
          throw ParserError.leaderKeyAlreadySet
        }

        shortcuts.append(try parseLeaderShortcut())
        parsedLeaderShortcut = true
      } else if check(type: .modifier) {
        shortcuts.append(try parseModifierShortcut())
      } else {
        throw ParserError.expectedModifierOrLeader
      }
    }

    return shortcuts
  }

  private func parseLeaderShortcut() throws -> LeaderShortcut {
    let (modifierFlags, keyCode) = try parseModifiersAndKey()
    let shortcut = LeaderShortcut(keyCode, modifierFlags)

    return shortcut
  }

  private func parseModifierShortcut() throws -> ModifierShortcut {
    let (modifierFlags, keyCode) = try parseModifiersAndKey()

    guard match(type: .command), let cmd = prevToken?.text else {
      throw ParserError.expectedColonFollowedByCommand
    }

    let action = ModifierShortcut.action(for: cmd)

    return ModifierShortcut(keyCode, modifierFlags, action)
  }

  private func parseModifiersAndKey() throws -> (modifiers: UInt32, key: UInt32) {
    let modifierFlags = try parseModifiers()

    guard match(type: .dash) else {
      throw ParserError.expectedModifierFollowedByDash
    }

    guard match(type: .key), let key = prevToken?.text else {
      throw ParserError.expectedDashFollowedByKey
    }

    let keyCode = Key.code(for: key)

    return (modifiers: modifierFlags, key: keyCode)
  }

  private func parseModifiers() throws -> UInt32 {
    var modifiers = [currToken?.text]
    advance()

    while match(type: .plus) {
      guard check(type: .modifier) else {
        throw ParserError.expectedPlusFollowedByModifier
      }

      modifiers.append(currToken?.text)
      advance()
    }

    return Modifier.flags(for: modifiers.compactMap { $0 })
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
