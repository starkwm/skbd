import Foundation

public enum AccessibilityPermission {
  public static func guidance(
    version: OperatingSystemVersion = ProcessInfo.processInfo.operatingSystemVersion,
    executableURL: URL? = Bundle.main.executableURL
  ) -> String {
    let pane =
      (version.majorVersion, version.minorVersion) >= (27, 3)
      ? "System & App Protection Override"
      : "Accessibility"
    let executable =
      executableURL.map { "\"\($0.resolvingSymlinksInPath().path)\"" } ?? "the skbd executable"

    return """
      Check Accessibility permission for skbd in System Settings > Privacy & Security > \(pane).
      Add \(executable), then restart skbd.
      If you upgraded or rebuilt skbd, remove the old entry and add the current executable again.
      """
  }
}
