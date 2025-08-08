enum ConfigError: Error {
  case configurationDoesNotExist
  case failedToMonitorConfigurationFile
}

extension ConfigError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .configurationDoesNotExist:
      return "configuration file or directory does not exist"
    case .failedToMonitorConfigurationFile:
      return "failed to monitor cofniguration file"
    }
  }
}
