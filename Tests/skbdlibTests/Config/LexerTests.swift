import XCTest

@testable import skbdlib

final class LexerTests: XCTestCase {
    // MARK: Lexer#getToken

    func testGetToken() {
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

        let expected: [TokenType] = [
            .comment,
            .modifier, .dash, .key, .command,
            .comment,
            .comment,
            .modifier, .plus, .modifier, .dash, .key, .command,
            .comment,
            .modifier, .plus, .modifier, .dash, .key, .command,
            .comment,
            .modifier, .dash, .key,
            .command,
            .comment,
            .modifier, .plus, .modifier, .dash, .key, .command,
            .comment,
            .modifier, .dash, .key, .command,
            .endOfStream,
        ]

        let lexer = Lexer(input)

        for type in expected {
            let token = lexer.getToken()
            XCTAssertEqual(token.type, type)
        }
    }

    func testGetTokenWithUnknownToken() {
        let lexer = Lexer("@")
        let token = lexer.getToken()

        XCTAssertEqual(token.type, .unknown)
    }

    func testGetTokenWithUnknownIdentifier() {
        let lexer = Lexer("cmd - f100: ls")

        let expected: [TokenType] = [
            .modifier, .dash, .unknown, .command,
        ]

        for type in expected {
            let token = lexer.getToken()
            XCTAssertEqual(token.type, type)
        }
    }
}
