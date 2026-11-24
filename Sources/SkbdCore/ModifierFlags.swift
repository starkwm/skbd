import Carbon

struct ModifierFlags: OptionSet, Hashable {
  static let alt = ModifierFlags(rawValue: 1 << 0)
  static let lalt = ModifierFlags(rawValue: 1 << 1)
  static let ralt = ModifierFlags(rawValue: 1 << 2)
  static let shift = ModifierFlags(rawValue: 1 << 3)
  static let lshift = ModifierFlags(rawValue: 1 << 4)
  static let rshift = ModifierFlags(rawValue: 1 << 5)
  static let cmd = ModifierFlags(rawValue: 1 << 6)
  static let lcmd = ModifierFlags(rawValue: 1 << 7)
  static let rcmd = ModifierFlags(rawValue: 1 << 8)
  static let ctrl = ModifierFlags(rawValue: 1 << 9)
  static let lctrl = ModifierFlags(rawValue: 1 << 10)
  static let rctrl = ModifierFlags(rawValue: 1 << 11)
  static let fn = ModifierFlags(rawValue: 1 << 12)

  private static let names: [(String, ModifierFlags)] = [
    ("alt", .alt), ("lalt", .lalt), ("ralt", .ralt),
    ("opt", .alt), ("lopt", .lalt), ("ropt", .ralt),
    ("cmd", .cmd), ("lcmd", .lcmd), ("rcmd", .rcmd),
    ("ctrl", .ctrl), ("lctrl", .lctrl), ("rctrl", .rctrl),
    ("shift", .shift), ("lshift", .lshift), ("rshift", .rshift),
    ("fn", .fn),
    ("meh", [.alt, .ctrl, .shift]),
    ("hyper", [.alt, .cmd, .ctrl, .shift]),
  ]

  private static let values: [String: ModifierFlags] = Dictionary(uniqueKeysWithValues: names)

  static func get(_ literal: String) -> ModifierFlags? {
    values[literal]
  }

  static func from(_ eventFlags: CGEventFlags) -> ModifierFlags {
    var result = Group.all.reduce(into: ModifierFlags()) { flags, group in
      flags.insert(group.from(eventFlags))
    }

    if eventFlags.contains(.maskSecondaryFn) {
      result.insert(.fn)
    }

    return result
  }

  static func matches(_ lhs: ModifierFlags, _ rhs: ModifierFlags) -> Bool {
    func matches(_ generic: ModifierFlags, _ left: ModifierFlags, _ right: ModifierFlags) -> Bool {
      lhs.contains(generic)
        ? rhs.contains(left)
          || rhs.contains(right)
          || rhs.contains(generic)
        : lhs.contains(left) == rhs.contains(left)
          && lhs.contains(right) == rhs.contains(right)
          && lhs.contains(generic) == rhs.contains(generic)
    }

    return Group.all.allSatisfy { group in
      matches(group.generic, group.left, group.right)
    } && lhs.contains(.fn) == rhs.contains(.fn)
  }

  let rawValue: UInt32

  private struct Group {
    static let all: [Group] = [
      .init(.alt, .lalt, .ralt, .maskAlternate, NX_DEVICELALTKEYMASK, NX_DEVICERALTKEYMASK),
      .init(.cmd, .lcmd, .rcmd, .maskCommand, NX_DEVICELCMDKEYMASK, NX_DEVICERCMDKEYMASK),
      .init(.ctrl, .lctrl, .rctrl, .maskControl, NX_DEVICELCTLKEYMASK, NX_DEVICERCTLKEYMASK),
      .init(.shift, .lshift, .rshift, .maskShift, NX_DEVICELSHIFTKEYMASK, NX_DEVICERSHIFTKEYMASK),
    ]

    let generic: ModifierFlags
    let left: ModifierFlags
    let right: ModifierFlags
    let mask: CGEventFlags
    let leftMask: CGEventFlags
    let rightMask: CGEventFlags

    private init(
      _ generic: ModifierFlags,
      _ left: ModifierFlags,
      _ right: ModifierFlags,
      _ mask: CGEventFlags,
      _ leftMask: Int32,
      _ rightMask: Int32
    ) {
      self.generic = generic
      self.left = left
      self.right = right
      self.mask = mask
      self.leftMask = CGEventFlags(rawValue: UInt64(leftMask))
      self.rightMask = CGEventFlags(rawValue: UInt64(rightMask))
    }

    func from(_ eventFlags: CGEventFlags) -> ModifierFlags {
      guard eventFlags.contains(mask) else { return [] }

      switch (eventFlags.contains(leftMask), eventFlags.contains(rightMask)) {
      case (true, false): return left
      case (false, true): return right
      case (true, true): return [left, right]
      default: return generic
      }
    }
  }
}

extension ModifierFlags: CustomStringConvertible {
  var description: String {
    guard !isEmpty else { return "<ModifierFlags none>" }

    let aliases: Set<String> = ["meh", "hyper", "opt", "lopt", "ropt"]

    let flags = Self.names.compactMap { (name, flag) in
      contains(flag) && !aliases.contains(name) ? name : nil
    }

    return "<ModifierFlags \(flags.joined(separator: "|"))>"
  }
}
