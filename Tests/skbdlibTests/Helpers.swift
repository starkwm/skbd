import Carbon
import XCTest

func createEventRef(signature: OSType, id: UInt32) -> EventRef? {
  var event: EventRef?

  let createStatus = CreateEvent(
    nil,
    OSType(kEventClassKeyboard),
    UInt32(kEventRawKeyDown),
    0,
    0,
    &event
  )

  guard createStatus == noErr, let eventRef = event else {
    XCTFail("Failed to create event: \(createStatus)")
    return nil
  }

  var eventHotKeyID = EventHotKeyID(signature: signature, id: id)

  let setStatus = SetEventParameter(
    eventRef,
    EventParamName(kEventParamDirectObject),
    EventParamType(typeEventHotKeyID),
    MemoryLayout<EventHotKeyID>.size,
    &eventHotKeyID
  )

  guard setStatus == noErr else {
    XCTFail("Failed to set event parameter: \(setStatus)")
    return nil
  }

  return eventRef
}

func createEventRefWithNoEventParameter() -> EventRef? {
  var event: EventRef?

  let createStatus = CreateEvent(
    nil,
    OSType(kEventClassKeyboard),
    UInt32(kEventRawKeyDown),
    0,
    0,
    &event
  )

  guard createStatus == noErr, let eventRef = event else {
    XCTFail("Failed to create event: \(createStatus)")
    return nil
  }

  return eventRef
}

func createEventRefWithInvalidEventHotKeySignature(eventHotKeyID: UInt32) -> EventRef? {
  var event: EventRef?

  let createStatus = CreateEvent(
    nil,
    OSType(kEventClassKeyboard),
    UInt32(kEventRawKeyDown),
    0,
    0,
    &event
  )

  guard createStatus == noErr, let eventRef = event else {
    XCTFail("Failed to create event: \(createStatus)")
    return nil
  }

  var eventHotKeyID = EventHotKeyID(signature: OSType(), id: eventHotKeyID)

  let setStatus = SetEventParameter(
    eventRef,
    EventParamName(kEventParamDirectObject),
    EventParamType(typeEventHotKeyID),
    MemoryLayout<EventHotKeyID>.size,
    &eventHotKeyID
  )

  guard setStatus == noErr else {
    XCTFail("Failed to set event parameter: \(setStatus)")
    return nil
  }

  return eventRef
}

func createEventRefWithInvalidEventHotKeyID() -> EventRef? {
  var event: EventRef?

  let createStatus = CreateEvent(
    nil,
    OSType(kEventClassKeyboard),
    UInt32(kEventRawKeyDown),
    0,
    0,
    &event
  )

  guard createStatus == noErr, let eventRef = event else {
    XCTFail("Failed to create event: \(createStatus)")
    return nil
  }

  var eventHotKeyID = EventHotKeyID(signature: OSType(), id: 0)

  let setStatus = SetEventParameter(
    eventRef,
    EventParamName(kEventParamDirectObject),
    EventParamType(typeEventHotKeyID),
    MemoryLayout<EventHotKeyID>.size,
    &eventHotKeyID
  )

  guard setStatus == noErr else {
    XCTFail("Failed to set event parameter: \(setStatus)")
    return nil
  }

  return eventRef
}
