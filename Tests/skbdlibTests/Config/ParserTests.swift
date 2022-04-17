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
        """

        do {
            let shortcuts = try Parser(input).parse()

            XCTAssertEqual(shortcuts[0].keyCode, UInt32(kVK_Space))
            XCTAssertEqual(shortcuts[0].modifierFlags, UInt32(optionKey))
            XCTAssertNotNil(shortcuts[0].handler)

            XCTAssertEqual(shortcuts[1].keyCode, UInt32(kVK_ANSI_A))
            XCTAssertEqual(shortcuts[1].modifierFlags, UInt32(cmdKey | shiftKey))
            XCTAssertNotNil(shortcuts[1].handler)

            XCTAssertEqual(shortcuts[2].keyCode, UInt32(kVK_Return))
            XCTAssertEqual(shortcuts[2].modifierFlags, UInt32(controlKey | optionKey))
            XCTAssertNotNil(shortcuts[2].handler)
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
}
