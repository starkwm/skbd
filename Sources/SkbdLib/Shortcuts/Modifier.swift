import Carbon

private let modifiersToCode: [String: Int] = [
  "shift": shiftKey,
  "ctrl": controlKey, "control": controlKey,
  "alt": optionKey, "opt": optionKey, "option": optionKey,
  "cmd": cmdKey, "command": cmdKey,
  "meh": optionKey | shiftKey | controlKey,
  "hyper": cmdKey | optionKey | shiftKey | controlKey,
]

enum Modifier {
  static func valid(_ modifier: String) -> Bool {
    modifiersToCode.keys.contains(modifier.lowercased())
  }

  static func flags(for modifiers: [String]) -> UInt32 {
    let mods = Set(modifiers.map { $0.lowercased() })

    var flags = 0

    for mod in mods {
      if let flag = modifiersToCode[mod] {
        flags |= flag
      }
    }

    return UInt32(flags)
  }
}
