import XCTest

@testable import skbdlib

class TokenTypeTests: XCTestCase {
  // MARK: TokenType#description

  func testTokenTypeComment() {
    let tokenType: TokenType = .comment
    XCTAssertEqual(tokenType, TokenType.comment)
    XCTAssertEqual(tokenType.description, "TokenType {Comment}")
  }

  func testTokenTypeModifier() {
    let tokenType: TokenType = .modifier
    XCTAssertEqual(tokenType, TokenType.modifier)
    XCTAssertEqual(tokenType.description, "TokenType {Modifier}")
  }

  func testTokenTypeKey() {
    let tokenType: TokenType = .key
    XCTAssertEqual(tokenType, TokenType.key)
    XCTAssertEqual(tokenType.description, "TokenType {Key}")
  }

  func testTokenTypeCommand() {
    let tokenType: TokenType = .command
    XCTAssertEqual(tokenType, TokenType.command)
    XCTAssertEqual(tokenType.description, "TokenType {Command}")
  }

  func testTokenTypePlus() {
    let tokenType: TokenType = .plus
    XCTAssertEqual(tokenType, TokenType.plus)
    XCTAssertEqual(tokenType.description, "TokenType {+}")
  }

  func testTokenTypeDash() {
    let tokenType: TokenType = .dash
    XCTAssertEqual(tokenType, TokenType.dash)
    XCTAssertEqual(tokenType.description, "TokenType {-}")
  }

  func testTokenTypeUnknown() {
    let tokenType: TokenType = .unknown
    XCTAssertEqual(tokenType, TokenType.unknown)
    XCTAssertEqual(tokenType.description, "TokenType {Unknown}")
  }

  func testTokenTypeEndOfStream() {
    let tokenType: TokenType = .endOfStream
    XCTAssertEqual(tokenType, TokenType.endOfStream)
    XCTAssertEqual(tokenType.description, "TokenType {End of Stream}")
  }
}
