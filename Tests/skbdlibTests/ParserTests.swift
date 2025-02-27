import Carbon
import Testing

@testable import skbdlib

@Suite("Parser")
struct ParserTests {
  // MARK: - Parser#parse

  @Test("Parser#parse() (with modifier shortcuts)")
  func parseWithModifierShortcuts() async throws {
    let input = """
          # this if the first comment, without whitespace
          opt-space:open -a iTerm2.app

          # this is a comment
          # with multiple lines... + - ++
          cmd + shift - a : echo "Hello world"

          # this is another comment, followed by a multiline command
          ctrl + opt - return : echo "foo bar"; \\
              rm -fr /

          meh - space: echo 'foo bar'

          # this is a comment with a hash in it # here
          hyper - f1:
              echo "# hello world"

          # this is a mapping with a number key
          ctrl + shift - 5: cat ~/.config/skbd/skbdrc | pbcopy

          # can use key symbols
          alt - [: echo "left bracket"
      """

    #expect(throws: Never.self) {
      let shortcuts = try Parser(input).parse()

      struct Expect {
        var key: UInt32
        var modifiers: UInt32
        var action: Bool
      }

      let expected = [
        Expect(key: UInt32(kVK_Space), modifiers: UInt32(optionKey), action: true),
        Expect(key: UInt32(kVK_ANSI_A), modifiers: UInt32(cmdKey | shiftKey), action: true),
        Expect(key: UInt32(kVK_Return), modifiers: UInt32(controlKey | optionKey), action: true),
        Expect(key: UInt32(kVK_Space), modifiers: UInt32(controlKey | optionKey | shiftKey), action: true),
        Expect(key: UInt32(kVK_F1), modifiers: UInt32(controlKey | optionKey | cmdKey | shiftKey), action: true),
        Expect(key: UInt32(kVK_ANSI_5), modifiers: UInt32(controlKey | shiftKey), action: true),
        Expect(key: UInt32(kVK_ANSI_LeftBracket), modifiers: UInt32(optionKey), action: true),
      ]

      #expect(shortcuts.count == expected.count)

      for (idx, expect) in expected.enumerated() {
        if let modifierShortcut = shortcuts[idx] as? ModifierShortcut {
          #expect(modifierShortcut.keyCode == expect.key)
          #expect(modifierShortcut.modifierFlags == expect.modifiers)
          #expect((modifierShortcut.action != nil) == expect.action)
        }
      }
    }
  }

  @Test("Parser#parse() (with leader shortcut)")
  func parseWithLeaderShortcut() async throws {
    let input = """
          # this setting the leader key shortcut
          leader: ctrl - space
      """

    #expect(throws: Never.self) {
      let shortcuts = try Parser(input).parse()

      struct Expect {
        var key: UInt32
        var modifiers: UInt32
        var action: Bool
      }

      let expected = [
        Expect(key: UInt32(kVK_Space), modifiers: UInt32(controlKey), action: false)
      ]

      #expect(shortcuts.count == expected.count)

      for (idx, expect) in expected.enumerated() {
        if let modifierShortcut = shortcuts[idx] as? LeaderShortcut {
          #expect(modifierShortcut.keyCode == expect.key)
          #expect(modifierShortcut.modifierFlags == expect.modifiers)
          #expect((modifierShortcut.action != nil) == expect.action)
        }
      }
    }
  }

  @Test("Parser#parse() (with sequence shortcuts in input)")
  func parseWithSequenceShortcuts() async throws {
    let input = """
        <leader> o b c: echo "leader o b c"

        <leader> o b s: echo "leader o b s"

        <leader> o b f: echo "leader o b f"
      """

    #expect(throws: Never.self) {
      let shortcuts = try Parser(input).parse()

      struct Expect {
        var keys: [UInt32]
      }

      let expected = [
        Expect(keys: [UInt32(kVK_ANSI_O), UInt32(kVK_ANSI_B), UInt32(kVK_ANSI_C)]),
        Expect(keys: [UInt32(kVK_ANSI_O), UInt32(kVK_ANSI_B), UInt32(kVK_ANSI_S)]),
        Expect(keys: [UInt32(kVK_ANSI_O), UInt32(kVK_ANSI_B), UInt32(kVK_ANSI_F)]),
      ]

      #expect(shortcuts.count == expected.count)

      for (idx, expect) in expected.enumerated() {
        if let sequenceShortcut = shortcuts[idx] as? SequenceShortcut {
          #expect(sequenceShortcut.keyCodes == expect.keys)
        }
      }
    }
  }

  @Test("Parser#parse() (with comment in input)")
  func parseWithComment() async throws {
    #expect(throws: Never.self) {
      let shortcuts = try Parser("# this is just a comment").parse()

      #expect(shortcuts.count == 0)
    }
  }

  @Test("Parser#parse() (with no modifier or leader)")
  func parseWithNoModifierOrLeader() async throws {
    #expect(throws: ParserError.expectedModifierOrLeader) {
      try Parser("space: open -a iTerm2.app").parse()
    }
  }

  @Test("Parser#parse() (with missing key)")
  func parseWithMissingKey() async throws {
    #expect(throws: ParserError.expectedKey) {
      try Parser("<leader> : true").parse()
    }
  }

  @Test("Parser#parse() (with invalid key)")
  func parseWithInvalidKey() async throws {
    #expect(throws: ParserError.expectedKey) {
      try Parser("<leader> >: true").parse()
    }
  }

  @Test("Parser#parse() (with no modifier after plus)")
  func parseWithNoModifierAfterPlus() async throws {
    #expect(throws: ParserError.expectedPlusFollowedByModifier) {
      try Parser("opt + : open -a iTerm2.app").parse()
    }
  }

  @Test("Parser#parse() (with no dash after modifier)")
  func parseWithNoDashAfterModifier() async throws {
    #expect(throws: ParserError.expectedModifierFollowedByDash) {
      try Parser("opt + ctrl : open -a iTerm2.app").parse()
    }
  }

  @Test("Parser#parse() (with no key after dash)")
  func parseWithNoKeyAfterDash() async throws {
    #expect(throws: ParserError.expectedDashFollowedByKey) {
      try Parser("opt + ctrl - : open -a iTerm2.app").parse()
    }
  }

  @Test("Parser#parse() (with no command after modifier shortcut)")
  func parseWithNoCommandAfterModifierShortcut() async throws {
    #expect(throws: ParserError.expectedColonFollowedByCommand) {
      try Parser("opt+ctrl-a+opt").parse()
    }
  }

  @Test("Parser#parse() (with multiple set leader)")
  func parseWithMultipleSetLeader() async throws {
    #expect(throws: ParserError.leaderKeyAlreadySet) {
      let input = """
          leader: ctrl - space
          leader: cmd - space
        """

      _ = try Parser(input).parse()
    }
  }

  @Test("Parser#parse() (with invalid keyword)")
  func parseWithInvalidKeyword() async throws {
    #expect(throws: ParserError.expectedLeaderKeyword) {
      try Parser("<foobar> a b c: true").parse()
    }
  }

  @Test("Parser#parse() (with missing keyword end)")
  func parseWithMissingKeywordEnd() async throws {
    #expect(throws: ParserError.expectedKeywordEnd) {
      try Parser("<leader a b c: true").parse()
    }
  }

  @Test("Parser#parse() (with no command after sequence shortcut)")
  func parseWithNoCommandAfterSequence() async throws {
    #expect(throws: ParserError.expectedColonFollowedByCommand) {
      try Parser("<leader> a b c").parse()
    }
  }
}
