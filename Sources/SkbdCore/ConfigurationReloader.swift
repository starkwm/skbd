import Foundation

public final class ConfigurationReloader: @unchecked Sendable {
  public static func loadConfiguration(from url: URL) throws -> Configuration {
    do {
      let input = try ConfigurationLoader.load(from: url)
      let parser = Parser(with: input)

      switch parser.parse() {
      case .success(let configuration):
        return configuration
      case .failure(let error):
        throw ConfigurationReloaderError.parseFailed(error)
      }
    } catch let error as ConfigurationReloaderError {
      throw error
    } catch {
      throw ConfigurationReloaderError.loadFailed(error)
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
      let configuration = try Self.loadConfiguration(from: url)
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
