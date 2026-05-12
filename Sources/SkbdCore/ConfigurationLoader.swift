import Foundation

public enum ConfigurationLoader {
  public static func load(from url: URL) throws -> String {
    let values = try url.resourceValues(forKeys: [.isDirectoryKey])

    if values.isDirectory == true {
      return try loadDirectory(at: url)
    }

    return try String(contentsOf: url, encoding: .utf8)
  }

  public static func regularFiles(in url: URL) throws -> [URL] {
    let fileManager = FileManager.default
    let entries = try fileManager.contentsOfDirectory(
      at: url,
      includingPropertiesForKeys: [.isRegularFileKey],
      options: [.skipsHiddenFiles]
    )

    return
      try entries
      .filter { entry in
        let values = try entry.resourceValues(forKeys: [.isRegularFileKey])
        return values.isRegularFile == true
      }
      .sorted { $0.lastPathComponent < $1.lastPathComponent }
  }

  private static func loadDirectory(at url: URL) throws -> String {
    return
      try regularFiles(in: url)
      .map { try String(contentsOf: $0, encoding: .utf8) }
      .joined(separator: "\n")
  }
}
