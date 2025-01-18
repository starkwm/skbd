/// A type for describing the version of skbd.
struct Version {
  /// The string value for the version.
  let value: String

  /// The current version of skbd.
  static let current = Self(value: "v0.0.5")
}
