enum ParserError: Error {
  case expectedModifierOrLeader
  case expectedPlusFollowedByModifier
  case expectedModifierFollowedByDash
  case expectedDashFollowedByKey
  case expectedColonFollowedByCommand
}

extension ParserError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .expectedModifierOrLeader:
      return "expected modifier or leader directive"
    case .expectedPlusFollowedByModifier:
      return "expected modifier to follow plus"
    case .expectedModifierFollowedByDash:
      return "expected dash to follow modifier"
    case .expectedDashFollowedByKey:
      return "expected key to follow dash"
    case .expectedColonFollowedByCommand:
      return "expected command to follow colon"
    }
  }
}
