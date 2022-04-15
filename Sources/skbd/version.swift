/// A type for describing the version of skbd.
struct Version {
    /// The string value for the version.
    let value: String

    /// The current version of skbd.
    static let current = Version(value: "0.0.0")
}
