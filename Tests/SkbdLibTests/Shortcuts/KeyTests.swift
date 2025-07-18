import Carbon
import Testing

@testable import SkbdLib

@Suite("Key")
struct KeyTests {
  // MARK: - Key.valid

  @Test("Key.valid() (with valid key identifier)")
  func validWithValidKeyIdentifier() async throws {
    #expect(Key.valid("A"))
  }

  @Test("Key.valid() (with invalid key identifier)")
  func validWithInvalidKeyIdentifier() async throws {
    #expect(Key.valid("XYZ") == false)
  }

  // MARK: - Key.code

  @Test("Key.code(for:) (with relocatable alpha key identifiers)")
  func codeWithRelocatableAlphaKeyIdentifiers() async throws {
    let tests = [
      "a": kVK_ANSI_A,
      "b": kVK_ANSI_B,
      "c": kVK_ANSI_C,
      "d": kVK_ANSI_D,
      "e": kVK_ANSI_E,
      "f": kVK_ANSI_F,
      "g": kVK_ANSI_G,
      "h": kVK_ANSI_H,
      "i": kVK_ANSI_I,
      "j": kVK_ANSI_J,
      "k": kVK_ANSI_K,
      "l": kVK_ANSI_L,
      "m": kVK_ANSI_M,
      "n": kVK_ANSI_N,
      "o": kVK_ANSI_O,
      "p": kVK_ANSI_P,
      "q": kVK_ANSI_Q,
      "r": kVK_ANSI_R,
      "s": kVK_ANSI_S,
      "t": kVK_ANSI_T,
      "u": kVK_ANSI_U,
      "v": kVK_ANSI_V,
      "w": kVK_ANSI_W,
      "x": kVK_ANSI_X,
      "y": kVK_ANSI_Y,
      "z": kVK_ANSI_Z,
    ]

    for (key, val) in tests {
      #expect(Key.code(for: key) == UInt32(val))
    }
  }

  @Test("Key.code(for:) (with relocatable numerical key identifiers)")
  func codeWithRelocatableNumericalKeyIdentifiers() async throws {
    let tests = [
      "0": kVK_ANSI_0,
      "1": kVK_ANSI_1,
      "2": kVK_ANSI_2,
      "3": kVK_ANSI_3,
      "4": kVK_ANSI_4,
      "5": kVK_ANSI_5,
      "6": kVK_ANSI_6,
      "7": kVK_ANSI_7,
      "8": kVK_ANSI_8,
      "9": kVK_ANSI_9,
    ]

    for (key, val) in tests {
      #expect(Key.code(for: key) == UInt32(val))
    }
  }

  @Test("Key.code(for:) (with relocatable symbol key identifiers)")
  func codeWithRelocatableSymbolKeyIdentifiers() async throws {
    let tests = [
      "`": kVK_ANSI_Grave,
      "-": kVK_ANSI_Minus,
      "=": kVK_ANSI_Equal,
      "[": kVK_ANSI_LeftBracket,
      "]": kVK_ANSI_RightBracket,
      ";": kVK_ANSI_Semicolon,
      "'": kVK_ANSI_Quote,
      "\\": kVK_ANSI_Backslash,
      ",": kVK_ANSI_Comma,
      ".": kVK_ANSI_Period,
      "/": kVK_ANSI_Slash,
    ]

    for (key, val) in tests {
      #expect(Key.code(for: key) == UInt32(val))
    }
  }

  @Test("Key.code(for:) (with non-relocatable key identifiers)")
  func codeWithNonRelocatableKeyIdentifiers() async throws {
    let tests = [
      "space": kVK_Space,
      "tab": kVK_Tab,
      "return": kVK_Return,
      "enter": kVK_Return,

      "caps_lock": kVK_CapsLock,
      "capslock": kVK_CapsLock,
      "caps": kVK_CapsLock,

      "page_up": kVK_PageUp,
      "pageup": kVK_PageUp,
      "page_down": kVK_PageDown,
      "pagedown": kVK_PageDown,
      "home": kVK_Home,
      "end": kVK_End,

      "up": kVK_UpArrow,
      "right": kVK_RightArrow,
      "down": kVK_DownArrow,
      "left": kVK_LeftArrow,

      "f1": kVK_F1,
      "f2": kVK_F2,
      "f3": kVK_F3,
      "f4": kVK_F4,
      "f5": kVK_F5,
      "f6": kVK_F6,
      "f7": kVK_F7,
      "f8": kVK_F8,
      "f9": kVK_F9,
      "f10": kVK_F10,
      "f11": kVK_F11,
      "f12": kVK_F12,
      "f13": kVK_F13,
      "f14": kVK_F14,
      "f15": kVK_F15,
      "f16": kVK_F16,
      "f17": kVK_F17,
      "f18": kVK_F18,
      "f19": kVK_F19,
      "f20": kVK_F20,

      "escape": kVK_Escape,
      "esc": kVK_Escape,
      "delete": kVK_Delete,
      "del": kVK_Delete,

      "grave": kVK_ANSI_Grave,
      "backtick": kVK_ANSI_Grave,
      "minus": kVK_ANSI_Minus,
      "dash": kVK_ANSI_Minus,
      "equal": kVK_ANSI_Equal,
      "equals": kVK_ANSI_Equal,
      "left_bracket": kVK_ANSI_LeftBracket,
      "leftbracket": kVK_ANSI_LeftBracket,
      "right_bracket": kVK_ANSI_RightBracket,
      "rightbracket": kVK_ANSI_RightBracket,
      "semicolon": kVK_ANSI_Semicolon,
      "quote": kVK_ANSI_Quote,
      "single_quote": kVK_ANSI_Quote,
      "singlequote": kVK_ANSI_Quote,
      "period": kVK_ANSI_Period,
      "comma": kVK_ANSI_Comma,
      "backslash": kVK_ANSI_Backslash,
      "slash": kVK_ANSI_Slash,
      "forward_slash": kVK_ANSI_Slash,
      "forwardslash": kVK_ANSI_Slash,
    ]

    for (key, val) in tests {
      #expect(Key.code(for: key) == UInt32(val))
    }
  }

  @Test("Key.code(for:) (with mixed casing key identifiers)")
  func codeWithMixedCasingKeyIdentifiers() async throws {
    let tests = [
      "spACe": UInt32(kVK_Space),
      "TAB": UInt32(kVK_Tab),
      "EScApE": UInt32(kVK_Escape),
    ]

    for (key, val) in tests {
      #expect(Key.code(for: key) == UInt32(val))
    }
  }

  @Test("Key.code(for:) (with unknown key identifiers)")
  func codeWithUnknownKeyIdentifier() async throws {
    #expect(Key.code(for: "asdf") == 0)
  }
}
