import Carbon
import Testing

@testable import skbdlib

@Suite("Modifier")
struct ModifierTests {
  // MARK: Modifier.valid

  @Test("Modifier.valid() (with valid modifier identifier)")
  func validWithValidModifierIdentifier() async throws {
    #expect(Modifier.valid("shift"))
  }

  @Test("Modifier.valid() (with invalid modifier identifier)")
  func validWithInvalidModifierIdentifier() async throws {
    #expect(!Modifier.valid("super-duper-modifier"))
  }

  // MARK: Modifier.flags

  @Test("Modifier.flags(for:) (with shift modifier identifiers)")
  func flagsWithShiftModifierIdentifiers() async throws {
    #expect(Modifier.flags(for: ["shift"]) == UInt32(shiftKey))
  }

  @Test("Modifier.flags(for:) (with control modifier identifiers)")
  func flagsWithControlModifierIdentifiers() async throws {
    #expect(Modifier.flags(for: ["ctrl"]) == UInt32(controlKey))
    #expect(Modifier.flags(for: ["control"]) == UInt32(controlKey))
  }

  @Test("Modifier.flags(for:) (with option modifier identifiers)")
  func flagsWithOptionModifierIdentifiers() async throws {
    #expect(Modifier.flags(for: ["alt"]) == UInt32(optionKey))
    #expect(Modifier.flags(for: ["opt"]) == UInt32(optionKey))
    #expect(Modifier.flags(for: ["option"]) == UInt32(optionKey))
  }

  @Test("Modifier.flags(for:) (with command modifier identifiers)")
  func flagsWithCommandModifierIdentifiers() async throws {
    #expect(Modifier.flags(for: ["cmd"]) == UInt32(cmdKey))
    #expect(Modifier.flags(for: ["command"]) == UInt32(cmdKey))
  }

  @Test("Modifier.flags(for:) (with hyper modifier identifiers)")
  func flagsWithHyperModifieirIdentifiers() async throws {
    #expect(Modifier.flags(for: ["hyper"]) == UInt32(cmdKey | optionKey | shiftKey | controlKey))
  }

  @Test("Modifier.flags(for:) (with multiple modifier identifiers)")
  func flagsWithMultipleModifierIdentifiers() async throws {
    #expect(Modifier.flags(for: ["shift", "ctrl", "alt", "cmd"]) == UInt32(shiftKey | controlKey | optionKey | cmdKey))
  }

  @Test("Modifier.flags(for:) (with mixed casing modifier identifiers)")
  func flagsWithMixedCasingModifierIdentifiers() async throws {
    #expect(Modifier.flags(for: ["shift", "CTRL", "AlT", "cMd"]) == UInt32(shiftKey | controlKey | optionKey | cmdKey))
  }

  @Test("Modifier.flags(for:) (with unknown modifier identifiers)")
  func flagsWithUnknownModifierIdentifiers() async throws {
    #expect(Modifier.flags(for: ["this-is-not-a-modifier"]) == 0)
  }
}
