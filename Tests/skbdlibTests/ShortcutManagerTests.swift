import Carbon
import XCTest

@testable import skbdlib

class ShortcutManagerTests: XCTestCase {
  override func tearDown() {
    ShortcutManager.stop()
    ShortcutManager.reset()
    ShortcutManager.registerEventHotKeyFunc = RegisterEventHotKey

    super.tearDown()
  }

  // MARK: shortcutEventHandler

  func testShortcutEventHandler() throws {
    let expectation = expectation(description: "handler executed")

    let shortcut = Shortcut(123, 456) { expectation.fulfill() }

    ShortcutManager.register(shortcut: shortcut)
    let box = try XCTUnwrap(ShortcutManager.box(for: shortcut))

    let event = createEventRef(signature: skbdEventHotKeySignature, id: box.eventHotKeyID)
    let status = shortcutEventHandler(nil, event: event, nil)

    XCTAssertEqual(status, noErr)

    waitForExpectations(timeout: 1.0, handler: nil)
  }

  // MARK: ShortcutManager.register

  func testRegisterShortcut() {
    let shortcut = Shortcut(123, 456)

    ShortcutManager.register(shortcut: shortcut)

    XCTAssertNotNil(ShortcutManager.box(for: shortcut))
  }

  func testRegisterSameShortcut() {
    let shortcut = Shortcut(123, 456)

    ShortcutManager.register(shortcut: shortcut)
    ShortcutManager.register(shortcut: shortcut)

    XCTAssertNotNil(ShortcutManager.box(for: shortcut))
  }

  func testRegisterShortcutWithoutKeyCode() {
    var shortcut = Shortcut()
    shortcut.modifierFlags = 456

    ShortcutManager.register(shortcut: shortcut)

    XCTAssertNil(ShortcutManager.box(for: shortcut))
  }

  func testRegisterShortcutWithouModifierFlags() {
    var shortcut = Shortcut()
    shortcut.keyCode = 123

    ShortcutManager.register(shortcut: shortcut)

    XCTAssertNil(ShortcutManager.box(for: shortcut))
  }

  func testRegisterWhenRegisterEventHotKeyFails() throws {
    ShortcutManager.registerEventHotKeyFunc = { (_, _, _, _, _, _) in OSStatus(eventHotKeyInvalidErr) }

    let shortcut = Shortcut(123, 456)

    ShortcutManager.register(shortcut: shortcut)

    XCTAssertNil(ShortcutManager.box(for: shortcut))
  }

  // MARK: ShortcutManager.unregister

  func testUnregisterShortcut() {
    let shortcut = Shortcut(123, 456)

    ShortcutManager.register(shortcut: shortcut)

    XCTAssertNotNil(ShortcutManager.box(for: shortcut))

    ShortcutManager.unregister(shortcut: shortcut)

    XCTAssertNil(ShortcutManager.box(for: shortcut))
  }

  func testUnregisterShortcutWithNeverRegisteredShortcut() {
    let shortcut = Shortcut(123, 456)

    ShortcutManager.unregister(shortcut: shortcut)

    XCTAssertNil(ShortcutManager.box(for: shortcut))
  }

  // MARK: ShortcutManager.start

  func testStart() {
    let shortcut = Shortcut(123, 456)

    ShortcutManager.register(shortcut: shortcut)

    XCTAssertTrue(ShortcutManager.start())
  }

  func testStartWithNoRegisteredShortcuts() {
    XCTAssertFalse(ShortcutManager.start())
  }

  func testStartWhenAlreadyStarted() {
    let shortcut = Shortcut(123, 456)

    ShortcutManager.register(shortcut: shortcut)

    XCTAssertTrue(ShortcutManager.start())
    XCTAssertFalse(ShortcutManager.start())
  }

  // MARK: ShortcutManager.stop

  func testStop() {
    let shortcut = Shortcut(123, 456)

    ShortcutManager.register(shortcut: shortcut)

    XCTAssertTrue(ShortcutManager.start())
    XCTAssertTrue(ShortcutManager.stop())
  }

  func testStopWhenNotStarted() {
    XCTAssertFalse(ShortcutManager.stop())
  }

  // MARK: ShortcutManager.reset

  func testReset() {
    let shortcut1 = Shortcut(123, 456)
    let shortcut2 = Shortcut(321, 654)

    ShortcutManager.register(shortcut: shortcut1)
    ShortcutManager.register(shortcut: shortcut2)

    XCTAssertNotNil(ShortcutManager.box(for: shortcut1))
    XCTAssertNotNil(ShortcutManager.box(for: shortcut2))

    ShortcutManager.reset()

    XCTAssertNil(ShortcutManager.box(for: shortcut1))
    XCTAssertNil(ShortcutManager.box(for: shortcut2))
  }

  // MARK: ShortcutManager.box

  func testBox() {
    let shortcut = Shortcut(123, 456)

    ShortcutManager.register(shortcut: shortcut)

    XCTAssertNotNil(ShortcutManager.box(for: shortcut))
  }

  func testBoxWithUnregisteredShortcut() {
    let shortcut = Shortcut(123, 456)

    XCTAssertNil(ShortcutManager.box(for: shortcut))
  }

  // MARK: ShortcutManager.handleCarbonEvent

  func testHandleCarbonEvent() throws {
    let expectation = expectation(description: "handler executed")

    let shortcut = Shortcut(123, 456) { expectation.fulfill() }

    ShortcutManager.register(shortcut: shortcut)
    let box = try XCTUnwrap(ShortcutManager.box(for: shortcut))

    let event = createEventRef(signature: skbdEventHotKeySignature, id: box.eventHotKeyID)
    let status = ShortcutManager.handleCarbonEvent(event)

    XCTAssertEqual(status, noErr)

    waitForExpectations(timeout: 1.0, handler: nil)
  }

  func testHandleCarbonEventWithNilEvent() {
    let status = ShortcutManager.handleCarbonEvent(nil)

    XCTAssertEqual(status, OSStatus(eventNotHandledErr))
  }

  func testHandleCarbonEventWithNoEventParamter() {
    let event = createEventRefWithNoEventParameter()
    let status = ShortcutManager.handleCarbonEvent(event)

    XCTAssertEqual(status, OSStatus(eventParameterNotFoundErr))
  }

  func testHandleCarbonEventWithInvalidSignature() throws {
    let shortcut = Shortcut(123, 456)

    ShortcutManager.register(shortcut: shortcut)
    let box = try XCTUnwrap(ShortcutManager.box(for: shortcut))

    let event = createEventRefWithInvalidEventHotKeySignature(eventHotKeyID: box.eventHotKeyID)
    let status = ShortcutManager.handleCarbonEvent(event)

    XCTAssertEqual(status, OSStatus(eventNotHandledErr))
  }

  func testHandleCarbonEventWithInvalidShortcutID() {
    let event = createEventRefWithInvalidEventHotKeyID()
    let status = ShortcutManager.handleCarbonEvent(event)

    XCTAssertEqual(status, OSStatus(eventNotHandledErr))
  }
}
