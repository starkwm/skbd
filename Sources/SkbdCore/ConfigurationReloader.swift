import Foundation

public final class ConfigurationReloader: @unchecked Sendable {
  public static func load(from url: URL) throws -> Configuration {
    let input: String

    do {
      input = try ConfigurationLoader.load(from: url)
    } catch {
      throw ConfigurationReloaderError.loadFailed(error)
    }

    do {
      return try Parser(with: input).parse().get()
    } catch {
      throw ConfigurationReloaderError.parseFailed(error)
    }
  }

  private let url: URL
  private let onReload: @Sendable (Configuration) -> Void
  private let onError: @Sendable (String) -> Void
  private var watcher: ConfigurationWatcher?

  public init(
    url: URL,
    onReload: @escaping @Sendable (Configuration) -> Void,
    onError: @escaping @Sendable (String) -> Void
  ) {
    self.url = url
    self.onReload = onReload
    self.onError = onError
  }

  public func start() {
    let watcher = ConfigurationWatcher(url: url) { [weak self] in
      self?.reload()
    }

    self.watcher = watcher
    watcher.start()
  }

  private func reload() {
    do {
      let configuration = try Self.load(from: url)

      onReload(configuration)
    } catch let error as ConfigurationReloaderError {
      onError(error.description)
    } catch {
      onError(error.localizedDescription)
    }
  }
}

public enum ConfigurationReloaderError: Error, CustomStringConvertible {
  case loadFailed(Error)
  case parseFailed(ParserError)

  public var description: String {
    switch self {
    case .loadFailed(let error):
      return "failed to load configuration: \(error.localizedDescription)"
    case .parseFailed(let error):
      return "error parsing the configuration file: \(error)"
    }
  }
}
