import Carbon
import XCTest

@testable import skbdlib

final class ParserTests: XCTestCase {
  // MARK: Parser#parse

  func testParse() {
    let input = """
          # this if the first comment, without whitespace
          opt-space:open -a iTerm2.app

          # this is a comment
          # with multiple lines... + - ++
          cmd + shift - a : echo "Hello world"

          # this is another comment, followed by a multiline command
          ctrl + opt - return : echo "foo bar"; \\
              rm -fr /

          # this is a comment with a hash in it # here
          hyper - f1:
              echo "# hello world"

          # this is a mapping with a number key
          ctrl + shift - 5: cat ~/.config/skbd/skbdrc | pbcopy

          # can use key symbols
          alt - [: echo "left bracket"
      """

    do {
      let shortcuts = try Parser(input).parse()

      struct Expect {
        var key: UInt32
        var modifiers: UInt32
      }

      let expected: [Expect] = [
        Expect(key: UInt32(kVK_Space), modifiers: UInt32(optionKey)),
        Expect(key: UInt32(kVK_ANSI_A), modifiers: UInt32(cmdKey | shiftKey)),
        Expect(key: UInt32(kVK_Return), modifiers: UInt32(controlKey | optionKey)),
        Expect(key: UInt32(kVK_F1), modifiers: UInt32(controlKey | optionKey | cmdKey | shiftKey)),
        Expect(key: UInt32(kVK_ANSI_5), modifiers: UInt32(controlKey | shiftKey)),
        Expect(key: UInt32(kVK_ANSI_LeftBracket), modifiers: UInt32(optionKey)),
      ]

      XCTAssertEqual(shortcuts.count, 6)

      for (idx, expect) in expected.enumerated() {
        XCTAssertEqual(shortcuts[idx].keyCode, expect.key)
        XCTAssertEqual(shortcuts[idx].modifierFlags, expect.modifiers)
        XCTAssertNotNil(shortcuts[idx].handler)
      }
    } catch {
      XCTFail("expected not to throw an error")
    }
  }

  func testParseWithComment() {
    let input = "# this is just a comment"

    XCTAssertNoThrow(try Parser(input).parse())
  }

  func testParseWithMissingModifier() {
    let input = "space: open -a iTerm2.app"

    XCTAssertThrowsError(try Parser(input).parse()) { err in
      XCTAssertTrue(err is ParserError)
      XCTAssertEqual(err as? ParserError, .expectedModifier)
    }
  }

  func testParseWithMissingModiferFollowingPlus() {
    let input = "opt + : open -a iTerm2.app"

    XCTAssertThrowsError(try Parser(input).parse()) { err in
      XCTAssertTrue(err is ParserError)
      XCTAssertEqual(err as? ParserError, .expectedPlusFollowedByModifier)
    }
  }

  func testParseWithMissingDashFollowingModifier() {
    let input = "opt + ctrl : open -a iTerm2.app"

    XCTAssertThrowsError(try Parser(input).parse()) { err in
      XCTAssertTrue(err is ParserError)
      XCTAssertEqual(err as? ParserError, .expectedModifierFollowedByDash)
    }
  }

  func testParseWithMissingKeyFollowingDash() {
    let input = "opt+ctrl-: open -a iTerm2.app"

    XCTAssertThrowsError(try Parser(input).parse()) { err in
      XCTAssertTrue(err is ParserError)
      XCTAssertEqual(err as? ParserError, .expectedDashFollowedByKey)
    }
  }

  func testParseWithMissingCommand() {
    let input = "opt+ctrl-a+opt"

    XCTAssertThrowsError(try Parser(input).parse()) { err in
      XCTAssertTrue(err is ParserError)
      XCTAssertEqual(err as? ParserError, .expectedColonFollowedByCommand)
    }
  }

  func testParseCanCallHandler() {
    do {
      let input = "opt+ctrl-a: echo"
      let shortcuts = try Parser(input).parse()

      XCTAssertEqual(shortcuts.count, 1)
      shortcuts[0].handler()
    } catch {
      XCTFail("expected not to throw an error")
    }
  }

  func testParseCanCallHandlerWhenShellIsEmpty() {
    do {
      setenv("SHELL", "", 1)

      let input = "opt+ctrl-a: echo"
      let shortcuts = try Parser(input).parse()

      XCTAssertEqual(shortcuts.count, 1)
      shortcuts[0].handler()
    } catch {
      XCTFail("expected not to throw an error")
    }
  }

  func testParseCanCallHandlerWhenShellIsNotSet() {
    do {
      unsetenv("SHELL")

      let input = "opt+ctrl-a: echo"
      let shortcuts = try Parser(input).parse()

      XCTAssertEqual(shortcuts.count, 1)
      shortcuts[0].handler()
    } catch {
      XCTFail("expected not to throw an error")
    }
  }
}
