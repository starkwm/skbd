import Foundation
import Testing

@testable import SkbdCore

@Suite("AccessibilityPermission")
struct AccessibilityPermissionTests {
  @Test(
    "guidance names the pane for the macOS version",
    arguments: [
      (26, 9, "Accessibility"),
      (27, 2, "Accessibility"),
      (27, 3, "System & App Protection Override"),
      (27, 4, "System & App Protection Override"),
      (28, 0, "System & App Protection Override"),
    ]
  )
  func paneForVersion(major: Int, minor: Int, pane: String) {
    let version = OperatingSystemVersion(majorVersion: major, minorVersion: minor, patchVersion: 0)
    let path = "/opt/homebrew/Cellar/skbd@2/0.0.8/bin/skbd"

    let guidance = AccessibilityPermission.guidance(
      version: version,
      executableURL: URL(fileURLWithPath: path)
    )

    #expect(guidance.contains("System Settings > Privacy & Security > \(pane)."))
    #expect(guidance.contains("\"\(path)\""))
  }
}
