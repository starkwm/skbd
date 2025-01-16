import XCTest

@testable import skbdlib

final class TokenTests: XCTestCase {
  // MARK: Token#description

  func testDescription() {
    let token = Token(type: .plus)

    XCTAssertEqual(token.description, "Token {type: TokenType {+}, text: nil}")
  }

  func testDescriptionWithText() {
    let token = Token(type: .command, text: "echo \"Hello World\"")

    XCTAssertEqual(token.description, "Token {type: TokenType {Command}, text: echo \"Hello World\"}")
  }
}
