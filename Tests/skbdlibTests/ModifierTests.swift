import Carbon
import XCTest

@testable import skbdlib

final class ModifierTests: XCTestCase {
  // MARK: Modifier.valid

  func testValid() {
    XCTAssertTrue(Modifier.valid("shift"))
  }

  func testValidWithInvalidModifier() {
    XCTAssertFalse(Modifier.valid("super-duper-modifier"))
  }

  // MARK: Modifier.flags

  func testFlagsWithShift() {
    XCTAssertEqual(Modifier.flags(for: ["shift"]), UInt32(shiftKey))
  }

  func testFlagsWithControl() {
    XCTAssertEqual(Modifier.flags(for: ["ctrl"]), UInt32(controlKey))
    XCTAssertEqual(Modifier.flags(for: ["control"]), UInt32(controlKey))
  }

  func testFlagsWithOption() {
    XCTAssertEqual(Modifier.flags(for: ["alt"]), UInt32(optionKey))
    XCTAssertEqual(Modifier.flags(for: ["opt"]), UInt32(optionKey))
    XCTAssertEqual(Modifier.flags(for: ["option"]), UInt32(optionKey))
  }

  func testFlagsWithCommand() {
    XCTAssertEqual(Modifier.flags(for: ["cmd"]), UInt32(cmdKey))
    XCTAssertEqual(Modifier.flags(for: ["command"]), UInt32(cmdKey))
  }

  func testFlagsWithHyper() {
    XCTAssertEqual(Modifier.flags(for: ["hyper"]), UInt32(cmdKey | optionKey | shiftKey | controlKey))
  }

  func testFlagsWithMultiple() {
    XCTAssertEqual(
      Modifier.flags(for: ["shift", "ctrl", "alt", "cmd"]),
      UInt32(shiftKey | controlKey | optionKey | cmdKey)
    )
  }

  func testFlagsCaseInsensitivity() {
    XCTAssertEqual(
      Modifier.flags(for: ["shift", "CTRL", "AlT", "cMd"]),
      UInt32(shiftKey | controlKey | optionKey | cmdKey)
    )
  }
}
