enum ConfigError: Error {
  case configurationDoesNotExist
}

extension ConfigError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .configurationDoesNotExist:
      return "configuration file or directory does not exist"
    }
  }
}
