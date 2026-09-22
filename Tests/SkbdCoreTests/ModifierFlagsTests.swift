import Carbon
import Testing

@testable import SkbdCore

@Suite("ModifierFlags")
struct ModifierFlagsTests {
  @Test("get(_:): alternative names")
  func optionAliases() {
    #expect(ModifierFlags.get("opt") == .alt)
    #expect(ModifierFlags.get("lopt") == .lalt)
    #expect(ModifierFlags.get("ropt") == .ralt)
  }

  @Test("from(_:): no modifiers")
  func noModifiers() {
    let eventFlags = CGEventFlags()

    #expect(ModifierFlags.from(eventFlags) == ModifierFlags())
  }

  @Test("from(_:): single modifier")
  func singleModifier() {
    var eventFlags = CGEventFlags()
    eventFlags.insert(.maskShift)

    #expect(ModifierFlags.from(eventFlags) == .shift)
  }

  @Test("from(_:): fn modifier")
  func fnModifier() {
    var eventFlags = CGEventFlags()
    eventFlags.insert(.maskSecondaryFn)

    #expect(ModifierFlags.from(eventFlags) == .fn)
  }

  @Test("from(_:): multiple modifiers")
  func multipleModifiers() {
    var eventFlags = CGEventFlags()
    eventFlags.insert(.maskAlternate)
    eventFlags.insert(.maskCommand)
    eventFlags.insert(.maskControl)
    eventFlags.insert(.maskShift)

    #expect(ModifierFlags.from(eventFlags) == [.alt, .cmd, .ctrl, .shift])
  }

  @Test("from(_:): left modifier")
  func leftModifier() {
    var eventFlags = CGEventFlags(
      rawValue: UInt64(NX_DEVICELALTKEYMASK)
    )
    eventFlags.insert(.maskAlternate)

    #expect(ModifierFlags.from(eventFlags) == .lalt)
  }

  @Test("from(_:): right modifier")
  func rightModifier() {
    var eventFlags = CGEventFlags(
      rawValue: UInt64(NX_DEVICERALTKEYMASK)
    )
    eventFlags.insert(.maskAlternate)

    #expect(ModifierFlags.from(eventFlags) == .ralt)
  }

  @Test("from(_:): left and right modifiers")
  func bothSides() {
    var eventFlags = CGEventFlags(
      rawValue: UInt64(NX_DEVICELALTKEYMASK | NX_DEVICERALTKEYMASK | NX_DEVICELCMDKEYMASK)
    )
    eventFlags.insert(.maskAlternate)
    eventFlags.insert(.maskCommand)

    #expect(ModifierFlags.from(eventFlags) == [.lalt, .ralt, .lcmd])
  }

  @Test("matches(_:_:): left and right modifiers")
  func matchingSides() {
    let mods: [(ModifierFlags, ModifierFlags)] = [
      (.lalt, .lalt),
      (.ralt, .ralt),
      (.lcmd, .lcmd),
      (.rcmd, .rcmd),
      (.lctrl, .lctrl),
      (.rctrl, .rctrl),
      (.lshift, .lshift),
      (.rshift, .rshift),
      (.fn, .fn),
    ]

    for (lhs, rhs) in mods {
      #expect(ModifierFlags.matches(lhs, rhs))
    }
  }

  @Test("matches(_:_:): generic modifiers")
  func genericModifiers() {
    let mods: [(ModifierFlags, ModifierFlags)] = [
      (.alt, .lalt),
      (.alt, .ralt),
      (.alt, .alt),
      (.cmd, .lcmd),
      (.cmd, .rcmd),
      (.cmd, .cmd),
      (.ctrl, .lctrl),
      (.ctrl, .rctrl),
      (.ctrl, .ctrl),
      (.shift, .lshift),
      (.shift, .rshift),
      (.shift, .shift),
      (.fn, .fn),
    ]

    for (lhs, rhs) in mods {
      #expect(ModifierFlags.matches(lhs, rhs))
    }
  }

  @Test("matches(_:_:): generic modifier matches left and right modifiers")
  func genericMatchesBothSides() {
    let mods: [(ModifierFlags, ModifierFlags)] = [
      (.alt, [.lalt, .ralt]),
      (.cmd, [.lcmd, .rcmd]),
      (.ctrl, [.lctrl, .rctrl]),
      (.shift, [.lshift, .rshift]),
    ]

    for (lhs, rhs) in mods {
      #expect(ModifierFlags.matches(lhs, rhs))
    }
  }

  @Test("matches(_:_:): multiple modifiers")
  func matchingCombinations() {
    let mods: [(ModifierFlags, ModifierFlags)] = [
      ([.lalt, .rcmd, .lctrl, .rshift], [.lalt, .rcmd, .lctrl, .rshift]),
      ([.alt, .cmd, .ctrl, .shift], [.lalt, .rcmd, .lctrl, .rshift]),
      ([.alt, .cmd, .ctrl, .shift], [.ralt, .lcmd, .rctrl, .lshift]),
    ]

    for (lhs, rhs) in mods {
      #expect(ModifierFlags.matches(lhs, rhs))
    }
  }

  @Test("Reject different modifiers")
  func mismatchedModifiers() {
    let cases: [(ModifierFlags, ModifierFlags)] = [
      (.lalt, .ralt),
      (.lcmd, .cmd),
      (.cmd, [.cmd, .shift]),
      ([.cmd, .fn], .cmd),
      (.cmd, [.cmd, .fn]),
      ([], .cmd),
      (.cmd, []),
    ]

    for (binding, event) in cases {
      #expect(!ModifierFlags.matches(binding, event))
    }
  }

  @Test("description: no modifiers")
  func emptyDescription() {
    #expect(ModifierFlags().description == "<ModifierFlags none>")
  }

  @Test("description: single modifier")
  func singleDescription() {
    let mods: [(ModifierFlags, String)] = [
      (.lalt, "<ModifierFlags lalt>"),
      (.ralt, "<ModifierFlags ralt>"),
      (.lcmd, "<ModifierFlags lcmd>"),
      (.rcmd, "<ModifierFlags rcmd>"),
      (.lctrl, "<ModifierFlags lctrl>"),
      (.rctrl, "<ModifierFlags rctrl>"),
      (.lshift, "<ModifierFlags lshift>"),
      (.rshift, "<ModifierFlags rshift>"),
      (.fn, "<ModifierFlags fn>"),
    ]

    for (modifiers, description) in mods {
      #expect(modifiers.description == description)
    }
  }

  @Test("description: multiple modifiers")
  func combinedDescription() {
    let mods: [(ModifierFlags, String)] = [
      ([.lalt, .ralt], "<ModifierFlags lalt|ralt>"),
      ([.shift, .ralt], "<ModifierFlags ralt|shift>"),
      ([.alt, .ctrl, .shift], "<ModifierFlags alt|ctrl|shift>"),
      ([.alt, .cmd, .ctrl, .shift], "<ModifierFlags alt|cmd|ctrl|shift>"),
      ([.rshift, .alt, .lctrl], "<ModifierFlags alt|lctrl|rshift>"),
    ]

    for (modifiers, description) in mods {
      #expect(modifiers.description == description)
    }
  }
}
