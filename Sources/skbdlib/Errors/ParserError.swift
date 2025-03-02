enum ParserError: Error {
  case expectedModifierOrLeader
  case expectedKey
  case expectedPlusFollowedByModifier
  case expectedModifierFollowedByDash
  case expectedDashFollowedByKey
  case expectedColonFollowedByCommand
  case leaderKeyAlreadySet
  case expectedLeaderKeyword
  case expectedKeywordEnd
}

extension ParserError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .expectedModifierOrLeader:
      return "expected modifier or leader directive"
    case .expectedKey:
      return "expected key"
    case .expectedPlusFollowedByModifier:
      return "expected modifier to follow plus"
    case .expectedModifierFollowedByDash:
      return "expected dash to follow modifier"
    case .expectedDashFollowedByKey:
      return "expected key to follow dash"
    case .expectedColonFollowedByCommand:
      return "expected command to follow colon"
    case .leaderKeyAlreadySet:
      return "leader key has already been set"
    case .expectedLeaderKeyword:
      return "expected leader keyword after keyword start"
    case .expectedKeywordEnd:
      return "expected keyword end after keyword"
    }
  }
}
