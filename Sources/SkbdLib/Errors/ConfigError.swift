import Foundation

enum ConfigError: Error, Equatable {
  case fileOrDirectoryDoesNotExist(path: URL)
}

extension ConfigError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .fileOrDirectoryDoesNotExist(let path):
      return "file or directory does not exist: \(path)"
    }
  }
}
