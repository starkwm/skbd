import Foundation

enum HotReloadError: Error {
  case fileOrDirectoryDoesNotExist(path: URL)
  case failedToWatchFileForChanges(path: URL)
}

extension HotReloadError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .fileOrDirectoryDoesNotExist(let path):
      return "file or directory does not exist: \(path)"
    case .failedToWatchFileForChanges(let path):
      return "failed to watch file for changes: \(path)"
    }
  }
}
