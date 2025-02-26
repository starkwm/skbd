import Carbon
import Testing

@testable import skbdlib

@Suite("Parser")
struct ParserTests {
  // MARK: - Parser#parse

  @Test("Parser#parse() (with valid input)")
  func parseWithValidInput() async throws {
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

          # this is a leader mappign
          leader: ctrl - space

          # can use key symbols
          alt - [: echo "left bracket"
      """

    #expect(throws: Never.self) {
      let shortcuts = try Parser(input).parse()

      struct Expect {
        var key: UInt32
        var modifiers: UInt32
        var leader: Bool
        var action: Bool
      }

      let expected = [
        Expect(key: UInt32(kVK_Space), modifiers: UInt32(optionKey), leader: false, action: true),
        Expect(key: UInt32(kVK_ANSI_A), modifiers: UInt32(cmdKey | shiftKey), leader: false, action: true),
        Expect(key: UInt32(kVK_Return), modifiers: UInt32(controlKey | optionKey), leader: false, action: true),
        Expect(
          key: UInt32(kVK_Space),
          modifiers: UInt32(controlKey | optionKey | shiftKey),
          leader: false,
          action: true
        ),
        Expect(
          key: UInt32(kVK_F1),
          modifiers: UInt32(controlKey | optionKey | cmdKey | shiftKey),
          leader: false,
          action: true
        ),
        Expect(key: UInt32(kVK_ANSI_5), modifiers: UInt32(controlKey | shiftKey), leader: false, action: true),
        Expect(key: UInt32(kVK_Space), modifiers: UInt32(controlKey), leader: true, action: false),
        Expect(key: UInt32(kVK_ANSI_LeftBracket), modifiers: UInt32(optionKey), leader: false, action: true),
      ]

      #expect(shortcuts.count == 8)

      for (idx, expect) in expected.enumerated() {
        #expect(shortcuts[idx].keyCode == expect.key)
        #expect(shortcuts[idx].modifierFlags == expect.modifiers)
        #expect(shortcuts[idx].isLeader == expect.leader)
        #expect((shortcuts[idx].action != nil) == expect.action)
      }
    }
  }

  @Test("Parser#parse() (with comment in input)")
  func parseWithComment() async throws {
    #expect(throws: Never.self) {
      try Parser("# this is just a comment").parse()
    }
  }

  @Test("Parser#parse() (with no modifier or leader directive in input)")
  func parseWithNoModifiers() async throws {
    #expect(throws: ParserError.expectedModifierOrLeader) {
      try Parser("space: open -a iTerm2.app").parse()
    }
  }

  @Test("Parser#parse() (with no additional modifier in input)")
  func parseWithNoAdditionalModifier() async throws {
    #expect(throws: ParserError.expectedPlusFollowedByModifier) {
      try Parser("opt + : open -a iTerm2.app").parse()
    }
  }

  @Test("Parser#parse() (with no dash after modifier in input)")
  func parseWithNoDashAfterModifier() async throws {
    #expect(throws: ParserError.expectedModifierFollowedByDash) {
      try Parser("opt + ctrl : open -a iTerm2.app").parse()
    }
  }

  @Test("Parser#parse() (with no key after dash in input)")
  func parseWithNoKeyAfterDash() async throws {
    #expect(throws: ParserError.expectedDashFollowedByKey) {
      try Parser("opt + ctrl - : open -a iTerm2.app").parse()
    }
  }

  @Test("Parser#parse() (with no command in input)")
  func parseWithNoCommand() async throws {
    #expect(throws: ParserError.expectedColonFollowedByCommand) {
      try Parser("opt+ctrl-a+opt").parse()
    }
  }

  @Test("Parser#parse() (with multiple leader directives)")
  func parseWithMultipleLeaders() async throws {
    #expect(throws: ParserError.leaderKeyAlreadySet) {
      let input = """
          leader: ctrl - space
          leader: cmd - space
        """

      _ = try Parser(input).parse()
    }
  }
}
